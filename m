From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: NFSROOT mount fails on SPARC after 2.6.37
Date: Fri, 04 Nov 2011 22:38:44 -0400
Message-ID: <1320460724.2750.24.camel@lade.trondhjem.org>
References: <1320429339.53513.YahooMailNeo@web24704.mail.ird.yahoo.com>
	 <119BC4C8-E1AB-4415-AF00-B183FC7EB16A@oracle.com>
	 <20111104.220334.1213367819937218830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-GLgANOly0l1BDLzU/O5InQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111104.220334.1213367819937218830.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-11-04 at 22:03 -0400, David Miller wrote: 
> Should be fixed by:
> 
> commit 3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c
> Author: Micha Nelissen <micha-NMpVyAPB7R5Fb86tMAXRjw@public.gmane.org>
> Date:   Thu May 19 10:14:06 2011 +0000
> 
>     ipconfig wait for carrier
>     
>     v3 -> v4: fix return boolean false instead of 0 for ic_is_init_dev
>     
>     Currently the ip auto configuration has a hardcoded delay of 1 second.
>     When (ethernet) link takes longer to come up (e.g. more than 3 seconds),
>     nfs root may not be found.
>     
>     Remove the hardcoded delay, and wait for carrier on at least one network
>     device.

What will happen if there is more than one NIC, but only one if those
NICs is being configured with a static IP address (i.e. no auto
configuration)?

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
