From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] skbuff: skb_segment: orphan frags before copying
Date: Tue, 11 Mar 2014 05:56:40 +0800
Message-ID: <20140310215640.GA15684@gondor.apana.org.au>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
 <1394468807-25980-6-git-send-email-mst@redhat.com>
 <20140310213404.GB15352@gondor.apana.org.au>
 <20140310215236.GA7052@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jbenc@redhat.com,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Simon Horman <horms@verge.net.au>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, Miklos Szeredi <mszeredi@suse.cz>,
	=?us-ascii?B?PT9VVEYtOD9xP1BldGVyPTIwUGFuPTI4PUU2PUJEPTk4PUU1PThEPUFC?=
	 =?us-ascii?B?PUU1PUI5PUIzPTI5Pz0=?= <panweiping3@gmail.com>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140310215236.GA7052@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 11:52:36PM +0200, Michael S. Tsirkin wrote:
>
> The cover letter has more detail:

For some reason I didn't receive this cover letter.
> 	skb_segment ... moves frags
> 	between skbs without orphaning them.
> 	This causes userspace to assume it's safe to
> 	reuse the buffer, and receiver gets corrupted data.
> 	This further might leak information from the
> 	transmitter on the wire.
> 
> if still unclear, pls let me know.

Why can't we deal with this by simply postponing the copy until
later? IOW if we pass along SKBTX_SHARED_FRAG will it work?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
