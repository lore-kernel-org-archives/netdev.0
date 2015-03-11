From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH 13/15] ieee802154: don't export static symbol
Date: Wed, 11 Mar 2015 19:17:04 +0100
Message-ID: <20150311181700.GA23342@omega>
References: <1426092997-30605-1-git-send-email-Julia.Lawall@lip6.fr>
 <1426092997-30605-14-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel@iogearbox.net,
	marcel@holtmann.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426092997-30605-14-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 11, 2015 at 05:56:35PM +0100, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> The semantic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r@
> type T;
> identifier f;
> @@
> 
> static T f (...) { ... }
> 
> @@
> identifier r.f;
> declarer name EXPORT_SYMBOL;
> @@
> 
> -EXPORT_SYMBOL(f);
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Acked-by: Alexander Aring <alex.aring@gmail.com>

Marcel can you please queue this into bluetooth-next, or even bluetooth?

Thanks.

- Alex
