From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Thu, 1 Dec 2011 17:06:20 +0900
Message-ID: <20111201080620.GH18436@verge.net.au>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
	<0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net>
	<20111128145157.GA17678@gondor.apana.org.au>
	<CAEP_g=_Mj9az1oSLzUcqT_m05JEJavjcQ1SFeoYtsgk5xvBjBQ@mail.gmail.com>
	<20111130070219.GB32630@gondor.apana.org.au>
	<20111201072418.GA18436@verge.net.au>
	<20111201075237.GA12799@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, "Fischer,
	Anna" <anna.fischer-VXdhtT5mjnY@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org" <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111201075237.GA12799-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 01, 2011 at 03:52:37PM +0800, Herbert Xu wrote:
> On Thu, Dec 01, 2011 at 04:24:18PM +0900, Simon Horman wrote:
> >
> > So while I agree that optimizing the hash is a good idea.  I don't believe
> > it is a bottle-neck at this point. Though I could be convinced otherwise if
> > long collision chains could be constructed with relatively few flows.
> > Something I had not considered until I rad your email just now.
> 
> It's not an optimisation issue, but a security one.  If you leave
> a hash like this with a constant seed, an attacker would have an
> infinite amount of time to find collisions.
> 
> Rehashing isn't all that difficult.

Sorry for missing the point. Yes, I agree that rehashing makes a lot of sense.
