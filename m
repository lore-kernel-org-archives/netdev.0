From: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Subject: Re: Linux v2.6.17-rc4
Date: Mon, 15 May 2006 06:27:19 +0100
Message-ID: <200605150627.19498.s0348365@sms.ed.ac.uk>
References: <Pine.LNX.4.64.0605111640010.3866@g5.osdl.org> <200605122219.37626.s0348365@sms.ed.ac.uk> <4466E2E8.7090801@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jeff@garzik.org, netdev@vger.kernel.org,
	Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mcr-smtp-001.bulldogdsl.com ([212.158.248.7]:59909 "EHLO
	mcr-smtp-001.bulldogdsl.com") by vger.kernel.org with ESMTP
	id S1751435AbWEOF1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 01:27:10 -0400
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <4466E2E8.7090801@nvidia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 14 May 2006 08:57, Ayaz Abdulla wrote:
> Alistair John Strachan wrote:
[snip]
> > There's been just a single commit since -rc3:
> >
> > forcedeth: fix multi irq issues
> > ebf34c9b6fcd22338ef764b039b3ac55ed0e297b
> >
> > However, it could have just been hidden since before -rc3, so I'll try to
> > work backwards if nobody has any immediate ideas..
>
> The interrupt handler could be called during the same time (on different
> cpu) the dev->stop function is clearing out the rings (nv_txrx_reset).

FWIW, I can't reproduce the fault with the commitdiff 
ebf34c9b6fcd22338ef764b039b3ac55ed0e297b reverted.

-- 
Cheers,
Alistair.

Third year Computer Science undergraduate.
1F2 55 South Clerk Street, Edinburgh, UK.
