From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net] bridge: do not expire mdb entry when
 bridge still uses it
Date: Fri, 8 Mar 2013 19:24:38 +0800
Message-ID: <20130308112438.GA29924@gondor.apana.org.au>
References: <1362708423-23932-1-git-send-email-amwang@redhat.com>
	<20130308023151.GA27155@gondor.apana.org.au>
	<1362710646.9773.25.camel@cr0>
	<20130308024726.GA27319@gondor.apana.org.au>
	<1362715613.9773.29.camel@cr0>
	<20130308040853.GA27704@gondor.apana.org.au>
	<1362727581.3237.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1362727581.3237.4.camel@cr0>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 08, 2013 at 03:26:21PM +0800, Cong Wang wrote:
>
> Hmm, what the user experiences is the multicast traffic between the
> bridge and some port is broken. Isn't this expected to work by default?

Oh I'm not arguing that this isn't a bug.  I'm trying to ensure
that we come up with the right fix.

> Or we can just change the default value of br->multicast_router to 2?

No because that will cause all sorts of stuff to be thrown at
the host.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
