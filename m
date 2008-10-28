From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v3)
Date: Tue, 28 Oct 2008 08:26:59 -0600
Message-ID: <fa686aa40810280726s338c739bl24ee53d3193292ba@mail.gmail.com>
References: <20081028103537.28951.4804.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
	 <8bd0f97a0810280350j385a0239if7a33928f7bb11f1@mail.gmail.com>
	 <4906F817.4050306@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Mike Frysinger" <vapier.adi@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:37501 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbYJ1O1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 10:27:00 -0400
In-Reply-To: <4906F817.4050306@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 5:31 AM, Paulius Zaleckas
<paulius.zaleckas@teltonika.lt> wrote:
> Mike Frysinger wrote:
>> On Tue, Oct 28, 2008 at 06:35, Paulius Zaleckas wrote:
>>> +config MDIO_GPIO
>>> +       tristate "Support for GPIO bitbanged MDIO buses"
>>>  config MDIO_OF_GPIO
>>>        tristate "Support for GPIO lib-based bitbanged MDIO buses"
>>
>> seems to me these drivers have the same description ...
>
> Yes... but it is MDIO_OF_GPIO description that needs changing...
> Should I make patch for it?

Wait a minute....  This is the same driver and it's just been
duplicated.  NAK.  Please don't do this.  Instead add a platform bus
binding to the existing driver.  Most of the code can be shared.

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
