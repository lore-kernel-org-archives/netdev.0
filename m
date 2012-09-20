From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 4/6] xfrm_user: fix info leak in copy_to_user_tmpl()
Date: Thu, 20 Sep 2012 09:26:08 +0200
Message-ID: <20120920072608.GB4221@secunet.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
 <1348090423-32665-5-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Brad Spengler <spender@grsecurity.net>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1348090423-32665-5-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2012 at 11:33:41PM +0200, Mathias Krause wrote:
> The memory used for the template copy is a local stack variable. As
> struct xfrm_user_tmpl contains multiple holes added by the compiler for
> alignment, not initializing the memory will lead to leaking stack bytes
> to userland. Add an explicit memset(0) to avoid the info leak.
> 
> Initial version of the patch by Brad Spengler.
> 
> Cc: Brad Spengler <spender@grsecurity.net>
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Patches 1-4:

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
