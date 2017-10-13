From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] Add -target to clang switch while cross compiling.
Date: Thu, 12 Oct 2017 18:14:01 -0700
Message-ID: <20171013011359.tyhynrjghe2krxec@ast-mbp>
References: <20171012231615.ugya5fa4mvrze6hw@ast-mbp>
 <1507852723-24677-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:52173 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753318AbdJMBOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 21:14:05 -0400
Content-Disposition: inline
In-Reply-To: <1507852723-24677-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 04:58:43PM -0700, Abhijit Ayarekar wrote:
> Update to llvm excludes assembly instructions.
> llvm git revision is below
> 
> commit 2865ab6996164e7854d55c9e21c065fad7c26569
> Author: Yonghong Song <yhs@fb.com>
> Date:   Mon Sep 18 23:29:36 2017 +0000
> 
>     bpf: add inline-asm support
> 
>     Signed-off-by: Yonghong Song <yhs@fb.com>
>     Acked-by: Alexei Starovoitov <ast@kernel.org>
> 
>     git-svn-id: https://llvm.org/svn/llvm-project/llvm/trunk@313593 91177308-0d34-0410-b5e6-96231b3b80d8

correct way to reference a commit is
commit 81eb8447daae ("ipv6: take care of rt6_stats")
Also I think git-svn-id link is broken. I'm not sure why llvm keeps
adding it to commits. Kernel's git history doesn't need them.
So just mention llvm commit in kernel's cannonical way and
mention that it will be part of llvm release 6.0
