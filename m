From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Sat, 14 Nov 2009 09:12:30 +0800
Message-ID: <20091114011229.GA18580@gondor.apana.org.au>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com> <20091110143652.GB19645@redhat.com> <4AF98A8C.9040201@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753499AbZKNBMd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AF98A8C.9040201@novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2009 at 10:45:16AM -0500, Gregory Haskins wrote:
>
> What I am getting at is as follows:  From a real basic perspective, you
> can look at all of this as a simple synchronous call (i.e. sendmsg()).
> The "app" (be it a userspace app, or a guest) prepares a buffer for
> transmission, and offers it to the next layer in the stack.  The app
> must maintain the integrity of that buffer at least until the layer
> below it signifies that it is "consumed".  This may mean its a
> synchronous call, like sendmsg(), or it may be asynchronous, like AIO.

Neither sendmsg() nor sendfile() is synchronous in the way you
imagine.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
