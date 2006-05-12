From: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Subject: Re: Linux v2.6.17-rc4
Date: Fri, 12 May 2006 22:19:37 +0100
Message-ID: <200605122219.37626.s0348365@sms.ed.ac.uk>
References: <Pine.LNX.4.64.0605111640010.3866@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	aabdulla@nvidia.com, jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mcr-smtp-001.bulldogdsl.com ([212.158.248.7]:51730 "EHLO
	mcr-smtp-001.bulldogdsl.com") by vger.kernel.org with ESMTP
	id S1750923AbWELVT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 17:19:29 -0400
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605111640010.3866@g5.osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 12 May 2006 00:44, Linus Torvalds wrote:
> Ok, I've let the release time between -rc's slide a bit too much again,
> but -rc4 is out there, and this is the time to hunker down for 2.6.17.
>
> If you know of any regressions, please holler now, so that we don't miss
> them.
>
> -rc4 itself is mainly random driver fixes (sound, infiniband, scsi,
> network drivers), but some splice fixes too and some arch (arm, powerpc,
> mips) updates. Shortlog follows,

Linus,

I've got an oops in the forcedeth driver on shutdown. Sorry for the crappy 
camera phone pictures, this board doesn't have RS232 ports:

http://devzero.co.uk/~alistair/oops-20060512/

It was initially difficult to reproduce, but I found I could do so reliably if 
I ssh'ed into the box and halted it remotely, then it would always oops on 
shutdown. I assume this is because the driver is still active when something 
happens to it during halt.

There's been just a single commit since -rc3:

forcedeth: fix multi irq issues
ebf34c9b6fcd22338ef764b039b3ac55ed0e297b

However, it could have just been hidden since before -rc3, so I'll try to work 
backwards if nobody has any immediate ideas..

-- 
Cheers,
Alistair.

Third year Computer Science undergraduate.
1F2 55 South Clerk Street, Edinburgh, UK.
