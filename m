From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Subject: Re: sshd segmentation fault on ia64 on 28-rc7-mmotm-081203 -
	bisected
Date: Wed, 10 Dec 2008 15:21:26 -0500
Message-ID: <1228940487.6139.68.camel@lts-notebook>
References: <1228322600.6693.61.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ia64 <linux-ia64@vger.kernel.org>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, fbuihuu@gmail.com
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <1228322600.6693.61.camel@lts-notebook>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2008-12-03 at 11:43 -0500, Lee Schermerhorn wrote:
> I couldn't find anything on the list about this.
> 
> I've built and booted 28-rc7-mmotm-081203 on both x86_64 and ia64.  I
> can ssh into the x86_64 platform fine.  On the ia64, I'm seeing sshd
> [from RHEL5 distro] seg faulting.  [Same sshd worked on the
> 28-rc6-mmotm-081201 kernel.]
> 
> Has anyone else seen this?
> 

I finally got around to bisecting this--sshd fails with SEGV on ia64--on
mmotm-081208.  It appears to be caused by the patch duo:

do_mpage_readpage-remove-first_logical_block-parameter.patch
do_mpage_readpage-remove-first_logical_block-parameter-fix.patch

Lee

