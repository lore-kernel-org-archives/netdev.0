From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [BUG] 2.6.33-rc1 gianfar error message
Date: Tue, 22 Dec 2009 10:32:49 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08FCA@zin33exm22.fsl.freescale.net>
References: <20091220214447.GA10233@trillian.comsick.at> <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net> <20091221072704.GA12110@gibson.comsick.at> <9F4C7D19E8361D4C94921B95BE08B81BA08F83@zin33exm22.fsl.freescale.net> <20091221163843.GB3529@gibson.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>
To: "Michael Guntsche" <mike@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:61672 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbZLVFCw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 00:02:52 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBM52qlb014380
	for <netdev@vger.kernel.org>; Mon, 21 Dec 2009 22:02:52 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nBM57Nl5021426
	for <netdev@vger.kernel.org>; Mon, 21 Dec 2009 23:07:24 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091221163843.GB3529@gibson.comsick.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: Michael Guntsche [mailto:mike@it-loops.com] 
>Sent: Monday, December 21, 2009 10:09 PM
>To: Kumar Gopalpet-B05799
>Cc: netdev
>Subject: Re: [BUG] 2.6.33-rc1 gianfar error message
>
>On 21 Dec 09 14:19, Kumar Gopalpet-B05799 wrote:
>> Michael,
>> 
>> Kindly try the following changes at your side and let me know the 
>> results. I couldn't test this as I don't have any TSEC 
>device with me.
><snip>
>
>Your patch did not apply to vanilla 2.6.32-rc1 at all. I patched the
>code myself and up to now I do not see any error messages. Uptime is at
>33 minutes, without the patch the error message appeared immediately
>after booting.
>
I am sorry about that, I forgot to mention that my patch was against
net-next-2.6 tree.

>Just for my understanding. Is the first diff part of the fix as well?
>With this change the FCB is only removed if there are padded bytes, why
>would this make a difference here?
>

Yes, the first diff portion is not required.

Also, if you confirm that the changes are working fine.
I will generate a clean patch and send it out.
Thanks for reporting it and testing it out.

--

Thanks
Sandeep
