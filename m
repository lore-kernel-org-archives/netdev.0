From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 4/5] lguest: use KVM hypercalls
Date: Thu, 16 Apr 2009 06:27:38 +0800
Message-ID: <20090415222738.GA15792@gondor.apana.org.au>
References: <20090415084717.GA8829@gondor.apana.org.au>
	<m18wm2rqy6.fsf@fess.ebiederm.org>
	<20090415132802.GA11408@gondor.apana.org.au>
	<m1skkaox8h.fsf@fess.ebiederm.org>
	<20090415134610.GA11683@gondor.apana.org.au>
	<m11vruovu5.fsf@fess.ebiederm.org>
	<20090415140819.GA11991@gondor.apana.org.au>
	<m1iql6m24b.fsf@fess.ebiederm.org>
	<20090415143834.GA12384@gondor.apana.org.au>
	<m1zleiklsl.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
	Matias Zabaljauregui <zabaljauregui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1zleiklsl.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2009 at 07:56:42AM -0700, Eric W. Biederman wrote:
>
> I still have the feeling that putting the socket in tun_file instead
> of in tun_struct might be conceptually cleaner, but one big blob that
> is allocated and destroyed together is certainly easier and a lot
> less racy to deal with.

As I said the difficulty with putting the socket in tun_file
is how do you get it on the RX callback path without introducing
new races.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
