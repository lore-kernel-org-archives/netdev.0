From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] multipath routing algorithm, better patch
Date: Fri, 1 Jul 2005 19:41:17 +0200
Message-ID: <20050701174117.GW16076__22320.7053299577$1120239572$gmane$org@postel.suug.ch>
References: <Pine.GSO.4.61.0506302014160.7400@rac1.wam.umd.edu> <42C4919A.5000009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Jenkins <patjenk@wam.umd.edu>, linux-kernel@vger.kernel.org,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42C4919A.5000009@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <42C4919A.5000009@trash.net> 2005-07-01 02:43
> Multiple algorithms can be compiled in at once, so this patch is wrong.
> mp_alg is supplied by userspace:
> 
>         if (rta->rta_mp_alg) {
>                 mp_alg = *rta->rta_mp_alg;
> 
>                 if (mp_alg < IP_MP_ALG_NONE ||
>                     mp_alg > IP_MP_ALG_MAX)
>                         goto err_inval;
>         }
> 
> If it isn't set correctly its an iproute problem. Did you actually
> experience any problems?

Well, my patch for iproute2 to enable multipath algorithm selection
is currently being merged to Stephen together with the ematch bits.
We had to work out a dependency on GNU flex first (the berkley
version uses the same executable names) so the inclusion was
delayed a bit.
