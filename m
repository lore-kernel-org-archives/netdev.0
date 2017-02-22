From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the kspp tree with the net-next tree
Date: Wed, 22 Feb 2017 07:35:12 +0100
Message-ID: <58AD3120.7020300@iogearbox.net>
References: <20170222110629.53d01cf5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Laura Abbott <labbott@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Kees Cook <keescook@google.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170222110629.53d01cf5@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/22/2017 01:06 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the kspp tree got a conflict in:
>
>    include/linux/filter.h
>
> between commit:
>
>    9d876e79df6a ("bpf: fix unlocking of jited image when module ronx not set")
>
> from the net-next tree and commit:
>
>    0f5bf6d0afe4 ("arch: Rename CONFIG_DEBUG_RODATA and CONFIG_DEBUG_MODULE_RONX")
>
> from the kspp tree.
>
> Hmmm, both these change the ifdef guards I have used the one from the
> net-next tree (CONFIG_ARCH_HAS_SET_MEMORY) for today, please let me know
> if that is not correct.

That's fine, thanks!
