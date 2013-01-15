From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter/xt_CT.c: fix uninitialized variable
Date: Tue, 15 Jan 2013 20:18:49 +0100
Message-ID: <20130115191849.GA17140@1984>
References: <1358276314-9536-1-git-send-email-dinggnu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Cong Ding <dinggnu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358276314-9536-1-git-send-email-dinggnu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Cong,

On Tue, Jan 15, 2013 at 07:58:34PM +0100, Cong Ding wrote:
> If CONFIG_NF_CONNTRACK_ZONES is not defined, the variable ret might be
> uninitialized when it goes to err1 through line 125 and 263 respectively.
> So I change these goto err1 to return -EINVAL directly.

This is already fixed in the net tree.

http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commit;h=4610476d89d53714ca94aae081fa035908bc137a
