From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sock: fix access via invalid file
 descriptor
Date: Wed, 10 Dec 2014 23:34:42 -0500 (EST)
Message-ID: <20141210.233442.1443408250525657088.davem@davemloft.net>
References: <1418271295-5829-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, davej@redhat.com, dborkman@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418271295-5829-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 10 Dec 2014 20:14:55 -0800

> 0day robot reported the following crash:
> [   21.233581] BUG: unable to handle kernel NULL pointer dereference at 0000000000000007
> [   21.234709] IP: [<ffffffff8156ebda>] sk_attach_bpf+0x39/0xc2
> 
> It's due to bpf_prog_get() returning ERR_PTR.
> Check it properly.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> Silly mistake. I was sure I've checked this error path. Apparently not :(

Applied, thanks Alexei.
