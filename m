From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: linux-next: manual merge of the target-merge tree with the
 net-next tree
Date: Mon, 29 Feb 2016 21:39:33 -0800
Message-ID: <1456810773.19657.197.camel@haakon3.risingtidesystems.com>
References: <20160229173911.4fabe3f8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	Varun Prakash <varun@chelsio.com>,
	target-devel <target-devel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160229173911.4fabe3f8@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-02-29 at 17:39 +1100, Stephen Rothwell wrote:
> Hi Nicholas,
> 
> Today's linux-next merge of the target-merge tree got a conflict in:
> 
>   drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
> 
> between commit:
> 
>   ba9cee6aa67d ("cxgb4/iw_cxgb4: TOS support")
> 
> from the net-next tree and commit:
> 
>   c973e2a3ff1b ("cxgb4: add definitions for iSCSI target ULD")
> 
> from the target-merge tree.
> 
> I fixed it up (the latter was a superset of the former) and can carry
> the fix as necessary (no action is required).
> 

Thanks Stephen.

I'll include a note to Linus in target-pending/for-next-merge PULL
request, and will plan to wait until after DaveM's net-next is merged
for v4.6-rc0.
