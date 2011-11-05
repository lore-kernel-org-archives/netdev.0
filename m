From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: NFSROOT mount fails on SPARC after 2.6.37
Date: Fri, 04 Nov 2011 22:03:34 -0400 (EDT)
Message-ID: <20111104.220334.1213367819937218830.davem@davemloft.net>
References: <1320429339.53513.YahooMailNeo@web24704.mail.ird.yahoo.com>
	<119BC4C8-E1AB-4415-AF00-B183FC7EB16A@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-GLgANOly0l1BDLzU/O5InQ@public.gmane.org
To: chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <119BC4C8-E1AB-4415-AF00-B183FC7EB16A-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Should be fixed by:

commit 3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c
Author: Micha Nelissen <micha-NMpVyAPB7R5Fb86tMAXRjw@public.gmane.org>
Date:   Thu May 19 10:14:06 2011 +0000

    ipconfig wait for carrier
    
    v3 -> v4: fix return boolean false instead of 0 for ic_is_init_dev
    
    Currently the ip auto configuration has a hardcoded delay of 1 second.
    When (ethernet) link takes longer to come up (e.g. more than 3 seconds),
    nfs root may not be found.
    
    Remove the hardcoded delay, and wait for carrier on at least one network
    device.
    
    Signed-off-by: Micha Nelissen <micha-NMpVyAPB7R5Fb86tMAXRjw@public.gmane.org>
    Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
