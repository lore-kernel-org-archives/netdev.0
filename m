From: wyang1 <Wei.Yang@windriver.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Thu, 25 Oct 2012 19:41:49 +0800
Message-ID: <5089257D.8060800@windriver.com>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com> <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net> <50883D03.1000600@windriver.com> <50883DB7.4030502@freescale.com>
Reply-To: <Wei.Yang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Manoil Claudiu-B08782 <B08782@freescale.com>
To: Timur Tabi <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47162 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab2JYLmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 07:42:23 -0400
In-Reply-To: <50883DB7.4030502@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2012 03:12 AM, Timur Tabi wrote:
> Paul Gortmaker wrote:
>> Even if it makes sense to convert the driver to of_xxx calls,
>> I think the obvious bug should be fixed as a separate commit,
>> so that the -stable folks have something to cherry pick.
> Oh, I agree with that.  I was just wondering why an OF-enabled driver
> would not use OF calls.  I've never seen that before.  My instinct is that
> the original developer had no idea what he was doing, but perhaps there is
> a very good reason for the way the driver is written.
>
okay, If have time, I will check the issue mentioned by you.:-)

Thanks
Wei
