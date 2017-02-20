From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the kspp tree with the net-next tree
Date: Mon, 20 Feb 2017 10:01:03 +0100
Message-ID: <58AAB04F.6010400@iogearbox.net>
References: <20170220105642.616b119b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Laura Abbott <labbott@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Kees Cook <keescook@google.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170220105642.616b119b@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2017 12:56 AM, Stephen Rothwell wrote:
> Hi Kees,
>
> Today's linux-next merge of the kspp tree got a conflict in:
>
>    include/linux/filter.h
>
> between commit:
>
>    74451e66d516 ("bpf: make jited programs visible in traces")
>
> from the net-next tree and commit:
>
>    0f5bf6d0afe4 ("arch: Rename CONFIG_DEBUG_RODATA and CONFIG_DEBUG_MODULE_RONX")
>
> from the kspp tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Looks good thanks!
