From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH 1/1] l2tp: cleanup l2tp_tunnel_delete calls
Date: Wed, 25 Oct 2017 16:27:16 +0200
Message-ID: <20171025142716.jpxjtfl7hm33g3li@alphalink.fr>
References: <20171025135755.25487-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171025135755.25487-1-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2017 at 03:57:55PM +0200, Jiri Slaby wrote:
> l2tp_tunnel_delete does not return anything since commit 62b982eeb458
> ("l2tp: fix race condition in l2tp_tunnel_delete").  But call sites of
> l2tp_tunnel_delete still do casts to void to avoid unused return value
> warnings.
> 
> Kill these now useless casts.
> 
Acked-by: Guillaume Nault <g.nault@alphalink.fr>
