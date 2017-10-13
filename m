From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] Add -target to clang switch while cross compiling.
Date: Fri, 13 Oct 2017 15:10:38 -0700
Message-ID: <20171013221036.jekimnr2i5linzid@ast-mbp>
References: <20171013011359.tyhynrjghe2krxec@ast-mbp>
 <1507922646-19260-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507922646-19260-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 13, 2017 at 12:24:06PM -0700, Abhijit Ayarekar wrote:
> Update to llvm excludes assembly instructions.
> llvm git revision is below
> 
> commit 65fad7c26569 ("bpf: add inline-asm support")
> 
> This change will be part of llvm  release 6.0
> 
> __ASM_SYSREG_H define is not required for native compile.
> -target switch includes appropriate target specific files
> while cross compiling
> 
> Tested on x86 and arm64.
> 
> Signed-off-by: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>

Thanks
Acked-by: Alexei Starovoitov <ast@kernel.org>
