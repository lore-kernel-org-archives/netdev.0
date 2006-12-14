From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 14:57:45 -0800
Message-ID: <87k60uaxw6.fsf@sycorax.lbl.gov>
References: <87psammchi.fsf@sycorax.lbl.gov>
	<20061214133023.0b266d8e@freekitty> <87odq6azel.fsf@sycorax.lbl.gov>
	<20061214144734.03300fa6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sycorax.lbl.gov ([128.3.5.196]:3999 "EHLO sycorax.lbl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbWLNW5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 17:57:50 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061214144734.03300fa6@freekitty> (message from Stephen
	Hemminger on Thu, 14 Dec 2006 14:47:34 -0800)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> Another useful bit of information is the statistics (ethtool -S eth0).
> When there were flow control bugs, they would show up as count of 1.

we'll see if the machine locks up again.

> Are you doing jumbo frames (MTU > 1500)?

no (or at least i don't think so). how can i tell?

assuming the machine doesn't lock up with msi interrupts disabled, do
you want me to do anything to debug why the driver locks up when the
msi interrupts are enabled?

--alex--

-- 
| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |
