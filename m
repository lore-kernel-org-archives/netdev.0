From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nft_counter: fix erroneous return values
Date: Mon, 15 Feb 2016 19:27:04 +0100
Message-ID: <20160215182704.GB3462@salvia>
References: <1454819479-6833-1-git-send-email-a.s.protopopov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anton Protopopov <a.s.protopopov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454819479-6833-1-git-send-email-a.s.protopopov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 06, 2016 at 11:31:19PM -0500, Anton Protopopov wrote:
> The nft_counter_init() and nft_counter_clone() functions should return
> negative error value -ENOMEM instead of positive ENOMEM.

Applied, thanks.
