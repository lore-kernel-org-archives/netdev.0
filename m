From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH v4 4/4] samples/bpf: Add documentation on cross
 compilation
Date: Wed, 20 Sep 2017 09:50:07 -0700
Message-ID: <ae375e99-d9ea-8176-2c73-dfcd19413a7e@infradead.org>
References: <20170920161159.25747-1-joelaf@google.com>
 <20170920161159.25747-4-joelaf@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alison@she-devel.com, juri.lelli@arm.com,
        fengc@google.com, daniel@iogearbox.net, davem@davemloft.net,
        ast@kernel.org, kernel-team@android.com
To: Joel Fernandes <joelaf@google.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920161159.25747-4-joelaf@google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/20/17 09:11, Joel Fernandes wrote:
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Joel Fernandes <joelaf@google.com>
> ---
>  samples/bpf/README.rst | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
> index 79f9a58f1872..2b906127ef54 100644
> --- a/samples/bpf/README.rst
> +++ b/samples/bpf/README.rst
> @@ -64,3 +64,13 @@ It is also possible to point make to the newly compiled 'llc' or
>  'clang' command via redefining LLC or CLANG on the make command line::
>  
>   make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
> +
> +Cross compiling samples
> +-----------------------
> +Inorder to cross-compile, say for arm64 targets, export CROSS_COMPILE and ARCH

   In order to

> +environment variables before calling make. This will direct make to build
> +samples for the cross target.
> +
> +export ARCH=arm64
> +export CROSS_COMPILE="aarch64-linux-gnu-"
> +make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
> 


-- 
~Randy
