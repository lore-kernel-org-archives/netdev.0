From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net
 tree
Date: Thu, 16 Feb 2012 15:47:04 +0200
Message-ID: <1329400024.16698.36.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20120216123803.8efe3d23eee5c3a80aceef61@canb.auug.org.au>
 <1329391450.16698.27.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	eilong@broadcom.com, eric.dumazet@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1329391450.16698.27.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-16 at 13:24 +0200, Yuval Mintz wrote:
> On Wed, 2012-02-15 at 17:38 -0800, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Today's linux-next merge of the net-next tree got a conflict in
> > drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c between commit
> > 66d885cba670 ("bnx2x: fix bnx2x_storm_stats_update() on big endian") from
> > the net tree and commit 1355b704b9ba ("bnx2x: consistent statistics after
> > internal driver reload") from the net-next tree.
> > 
> > I fixed it up (see below) but suspect that there may be more needed.
> 
> Hey Stephen,
> 
> I don't fully understand your merge - it seems to create a mash between
> the "bnx2x: fix bnx2x_storm_stats_update() on big endian" patch in net,
> and the "bnx2x: consistent statistics after internal driver reload"
> patch in net-next.
> 
> If the purpose of this merge is simply to update net-next tree with the
> changes from "bnx2x: fix bnx2x_storm_stats_update() on big endian", you
> might consider the following patch:
> 
> Subject: [PATCH 1/1] bnx2x: merge net --> net-next
> From: Mintz Yuval <yuvalmin@broadcom.com>
> 
> This patch applies the changes made in the patch
> "bnx2x: fix bnx2x_storm_stats_update() on big endian" to net into net-next.
> 
> Signed-off-by: Mintz Yuval <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
We need of course to thank Eric Dumazet <eric.dumazet@gmail.com> for the
original patch.
