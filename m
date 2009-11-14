From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Sat, 14 Nov 2009 10:51:35 +0800
Message-ID: <20091114025135.GA19289@gondor.apana.org.au>
References: <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com> <20091110143652.GB19645@redhat.com> <4AF98A8C.9040201@novell.com> <20091114011229.GA18580@gondor.apana.org.au> <4AFE08EF.2030308@gmail.com> <20091114022103.GA19020@gondor.apana.org.au> <4AFE15AD.6000208@gmail.com> <20091113184503.13f6d447@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Gregory Haskins <ghaskins@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756975AbZKNCvk@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091113184503.13f6d447@s6510>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 13, 2009 at 06:45:03PM -0800, Stephen Hemminger wrote:
> 
> No all the interfaces require a copy. Actually, sendfile makes no guarantee about synchronization

Actually sendfile does not require a copy.

> because the receiver of said file could be arbitrarily slow, and any attempt at locking down
> current contents of file is a denial of service exposure.

Agreed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
