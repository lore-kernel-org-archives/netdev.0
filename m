From: Horst von Brand <vonbrand@inf.utfsm.cl>
Subject: Re: TCP rto estimation patch
Date: Fri, 23 Apr 2004 13:35:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404231735.i3NHZRp3012111@eeyore.valparaiso.cl>
References: <weddy@grc.nasa.gov>
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: weddy@grc.nasa.gov
In-Reply-To: Message from Wesley Eddy <weddy@grc.nasa.gov>
   of "Fri, 23 Apr 2004 10:24:45 -0400." <20040423142445.GC501@grc.nasa.gov>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wesley Eddy <weddy@grc.nasa.gov> said:
> The TCP RTO estimation algorithm defined in RFC 2988 is followed properly
> in the kernel, however the constants alpha and beta in the specification
> are hardcoded as 3 and 2 everywhere they occur in the kernel.  Since these
> constants crop up multiple times, this is poor programming practice.  This
> patch binds the numeric values to symbols RTT_ALPHA and RTTVAR_BETA, and
> uses those symbolic values throughout the code.  Since using 2 and 3 for
> these values is not mandatory, this makes tweaking them much easier.

Why RTT_ALPHA and RTTVAR_BETA, and not just RTT_BETA? Or even RTO_xxx?

Is there any reason to change them, ever? What happens if you change them?
Restrictions on values? All this should go with such a patch IMHO (at least
pointers to relevant discussion).

Must go over it with a fine comb to make sure no unrelated 2 or 3 got
replaced... out of my league, sorry.

Your patch is MIME-mangled, =3D, =20, =\n shows up all over the place here.
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
