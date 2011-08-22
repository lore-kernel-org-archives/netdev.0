From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 4/4] drivers/net/wireless/mwifiex/scan.c: test the
 just-initialized value
Date: Mon, 22 Aug 2011 16:12:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1108221612090.10948@ask.diku.dk>
References: <1314021636-11528-4-git-send-email-julia@diku.dk>
 <4E52638C.8080407@inria.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bing Zhao <bzhao@marvell.com>, kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pierre Louis Aublin <pierre-louis.aublin@inria.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E52638C.8080407@inria.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Aug 2011, Pierre Louis Aublin wrote:

> Hello all
> 
> On 08/22/2011 04:00 PM, Julia Lawall wrote:
> > -	if (!bss_desc) {
> > +	if (!beacon_ie) {
> >     dev_err(priv->adapter->dev, " failed to alloc bss_desc\n");
> Shouldn't we also modify the error message, from "failed to alloc bss_desc" to
> "failed to alloc beacon_ie" ?

Sure :)

julia
