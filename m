From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Mon, 20 Feb 2017 10:02:36 +0100
Message-ID: <58AAB0AC.9080601@iogearbox.net>
References: <20170220122227.54f04c2a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Masami Hiramatsu <mhiramat@kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170220122227.54f04c2a@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2017 02:22 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the tip tree got a conflict in:
>
>    kernel/extable.c
>
> between commit:
>
>    74451e66d516 ("bpf: make jited programs visible in traces")
>
> from the net-next tree and commit:
>
>    5b485629ba0d ("kprobes, extable: Identify kprobes trampolines as kernel text area")
>
> from the tip tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Looks good to me, thanks!
