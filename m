From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: this cpu documentation
Date: Thu, 04 Apr 2013 11:35:55 -0700
Message-ID: <515DC80B.5090403@infradead.org>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com> <1364475933.15753.36.camel@edumazet-glaptop> <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com> <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com> <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com> <1364833887.5113.161.camel@edumazet-glaptop> <0000013dd1a20ebf-4a76fb06-4b9d-492e-9d77-4b3f43aceca7-000000@email.amazonses.com> <515F679E.8020203@infradead.org> <0000013dd57e7ad7-d5959142-ca41-4a53-9497-7559766aafc9-000000@email.amazonses.com> <515DB623.4060802@infradead.org> <0000013dd622cebd-a7fee90b-b297-4e92-9143-87f4771718a4-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org,
	Tejun Heo <htejun@gmail.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50447 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761648Ab3DDSgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 14:36:03 -0400
In-Reply-To: <0000013dd622cebd-a7fee90b-b297-4e92-9143-87f4771718a4-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/13 10:40, Christoph Lameter wrote:
> On Thu, 4 Apr 2013, Randy Dunlap wrote:
> 
>> Thanks.  I have a few more corrections to V2 (please see below).
> 
> From: Christoph Lameter <cl@linux.com>
> Subject: this_cpu: Add documentation V3
> 
> Document the rationale and the way to use this_cpu operations.
> 
> V2/V3: Improved after feedback from Randy Dunlap
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/Documentation/this_cpu_ops
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux/Documentation/this_cpu_ops	2013-04-04 12:39:38.479720028 -0500
> @@ -0,0 +1,197 @@
> +
> +Access to the variable without the lock prefix is not synchronized but
> +synchronization is not necessary since we are dealing with per cpu data
> +specific to the currently executing processor. Only the current processor
> +should be accessing that variable and therefore there are no concurirency

                                                                concurrency
again.  but hopefully Tejun has already corrected that.

Thanks.

> +issues with other processors in the system.
> +


-- 
~Randy
