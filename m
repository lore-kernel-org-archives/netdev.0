From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Mon, 28 Nov 2011 09:02:34 -0500
Message-ID: <1322488954.7338.66.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111128130409.GB16828-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
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

On Mon, 2011-11-28 at 21:04 +0800, Herbert Xu wrote:

> You're right, a new classifier for the hash table would be the
> best option.
>  
> > I cant find one - you may. After staring at the code, I am also now
> > questioning if the existing bridge code couldnt have been re-used with
> > some small tweaks.
> 
> I wasn't able to find any functionality that could not be easily
> done with the existing classifier/action code.

Thanks for validating Herbert. 

> Whether we want to go down this route though is open to debate
> as someone would have to actually implement this :)

I empathize that effort has been invested in coding the way it was. 
But this is where an RFC to netdev would have been useful instead of
reinventing things. I dont see it as a huge effort really; the
refactoring should be mostly in user space.

Along the same lines:
Even for the integration with existing silicon I am worried that using
openvswitch as a proxy is not the right thing to do (the Intel approach
or the DSA approach where Linux is the proxy is the right thing to
do(TM).

> However, what's more worrying for me right now is the gaping
> DoS opportunities that exist in the patch as is.
> 
> In particular, the whole design principle of punting all new
> flows to user-space is an excellent way of attacking the system.

Indeed this is an issue with openflow in general.
The general solution is to rate limit how much goes to the controller
but even that is insufficient.

cheers,
jamal
