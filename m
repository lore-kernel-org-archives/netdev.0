From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/9] arcnet fixes
Date: Fri, 29 Oct 2004 13:39:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029133923.66dd719f.akpm@osdl.org>
References: <20041028164111.5ffaca70.davem@redhat.com>
	<Pine.OSF.4.05.10410291603000.5037-100000@da410.ifa.au.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Esben Nielsen <simlo@phys.au.dk>
In-Reply-To: <Pine.OSF.4.05.10410291603000.5037-100000@da410.ifa.au.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Esben Nielsen <simlo@phys.au.dk> wrote:
>
> > One problem with the patch though.
>  > 
>  > > diff -puN include/linux/if_ether.h~arcnet-fixes include/linux/if_ether.h
>  > > --- 25/include/linux/if_ether.h~arcnet-fixes	2004-10-28 00:17:07.230704752 -0700
>  > > +++ 25-akpm/include/linux/if_ether.h	2004-10-28 00:17:07.247702168 -0700
>  > > @@ -91,6 +91,7 @@
>  > >  #define ETH_P_IRDA	0x0017		/* Linux-IrDA			*/
>  > >  #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
>  > >  #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
>  > > +#define ETH_P_ARCNET	0x0020		/* ArcNet			*/
>  > 
>  > You should use 0x001a or similar, so you don't have
>  > to do this next part of your patch, bumping NPROTO
>  > in net.h
>  > 
> 
>  Doh! I can't count in hex it seems. This would probably also mean I won't
>  have to recompile the whole kernel but just the modules and I don't have 
>  to reboot to make it work on a new machine - but just until somebody else
>  picks the same protocol number ofcourse.
> 
>  Do I have to fix the problem and resubmit?

Yes please.  A patch relative to the previous one would be nice.
