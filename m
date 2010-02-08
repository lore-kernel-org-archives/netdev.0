From: Mike Rapoport <mike@compulab.co.il>
Subject: Re: smsc911x suspend/resume
Date: Mon, 08 Feb 2010 16:42:25 +0200
Message-ID: <4B7022D1.5030408@compulab.co.il>
References: <4B6FDC83.9090205@compulab.co.il> <20100208101123.GW28972@buzzloop.caiaq.de> <4B6FF5E2.6060304@compulab.co.il> <20100208114638.GO9007@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org,
	LAKML <linux-arm-kernel@lists.infradead.org>
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from compulab.co.il ([67.18.134.219]:33938 "EHLO compulab.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804Ab0BHOnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 09:43:22 -0500
In-Reply-To: <20100208114638.GO9007@buzzloop.caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack wrote:
> On Mon, Feb 08, 2010 at 01:30:42PM +0200, Mike Rapoport wrote:
>> Daniel Mack wrote:
>>> What happens to your supply voltages when going to suspend? When I
>>> implemented the code for the smsc driver, I could only test scenarios
>>> where AVDD remains stable during suspend. So the driver might need some
>>> tweaks if that assumption is not true in your case. The SMSC datasheet
>>> is quite comprehensive about this topic IIRC.
>> By AVDD you mean VDD33A?
> 
> Yes.
> 
>> Anyway, I have all the supplies except VDDVARIO shut down...
>> And the datasheet is indeed comprehensively describes chip power states
>> but I haven't found there anything about supplies required to stay on
>> during suspend...
> 
> In fact the datasheet doesn't really state that, and the chip seems
> to expect the power domains to remain switched on during suspend, and
> all power switching is done internally. Also the table in "7.4 Power
> Consumption (Device and System Components)" describes it like that.
> 
> So it all comes down to the question of how low-power you need to be,
> and whether you need wake-on-lan or not. What's currently implemented is
> D1, but adding support for D2 should be easy.

I did some brute force save/restore of smsc9220 registers and it seems
to wake up now.
The question now is how to make it in a "generic" way ...
Thanks for the help anyway :)

> Daniel


-- 
Sincerely yours,
Mike.
