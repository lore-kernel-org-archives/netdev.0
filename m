From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] Add -target to clang switch while cross compiling.
Date: Sun, 15 Oct 2017 01:10:25 +0200
Message-ID: <59E29961.30703@iogearbox.net>
References: <20171013011359.tyhynrjghe2krxec@ast-mbp> <1507922646-19260-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>,
        ast@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507922646-19260-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/13/2017 09:24 PM, Abhijit Ayarekar wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
