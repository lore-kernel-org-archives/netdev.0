From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 26 Aug 2008 15:03:38 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808261449320.4551@wrl-59.cs.helsinki.fi>
References: <200808251845.41164.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="Boundary-00=_1GusI+sJ3SlMh79"
Cc: Netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200808251845.41164.thomas.jarosch@intra2net.com>
Content-ID: <Pine.LNX.4.64.0808261449321.4551@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--Boundary-00=_1GusI+sJ3SlMh79
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808261449322.4551@wrl-59.cs.helsinki.fi>
Content-Disposition: inline

On Mon, 25 Aug 2008, Thomas Jarosch wrote:

> On Friday, 22. August 2008 23:18:44 Ilpo Järvinen wrote:
> > In the meantime, can you check the attached patches. Besides the kernel
> > patch, you need to build your own patched iproute2 as well to configure
> > the features (ip tool among them is enough in case the build of some other
> > part of the toolset fails like it did for me). I somewhat tested them, and
> > the result seemed to be what I'd expect (I just forced RTOs with some
> > netem heavy dropping and quickly glanced over the resulting packet
> > patterns near RTO).
> 
> Your patches work fine.

Thanks for testing.

> I've noticed two small things:
> 1. Maybe it's a good idea to add a note above the tcp_use_frto() change
> to explain that the value is negated. Took me a while to figure out
> why there is no "!" in there :-)
> 2. Maybe rename the "features" option in iproute2 to "disable_features".
> Then it would be more intuitive what it does.

First of all I hate doing anything which has an user interface stamp in 
it... :-)

Second, didn't I write about this negation in some of the log messages... 
/me looks for that... hmm... I think I did ...and that's besides the very 
clear help text :-). 

Yeah, it was just that the earlier ip already prints the field as 
"features" though I guess changing also that is a non-problem to existing 
userspace stuff because of the current usage of the field. There's this 
RTAX_FEATURE_ALLFRAG stuff which somebody could be looking for but I 
don't know how likely that will be.

But anyway, point taken. I'll try to change both to disable_features and 
see if that gets accepted.

-- 
 i.
--Boundary-00=_1GusI+sJ3SlMh79--
