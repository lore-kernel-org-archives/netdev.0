From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: conntrack: add a new
 NF_CT_EXT_EXPAND extension
Date: Mon, 26 Jun 2017 18:52:15 +0200
Message-ID: <20170626165215.GA6562@salvia>
References: <1498457446-30135-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498457446-30135-1-git-send-email-xiaolou4617@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2017 at 02:10:46PM +0800, Lin Zhang wrote:
>   In the current conntrack extend code, if we want to add a new
> extension, we must be add a new extension id and recompile kernel.

Yes, this is designed in this way on purpose.

Because we do not want to endorse proliferation of out-of-tree kernel
modules.

Sorry, we cannot take this.
