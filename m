From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4] {net,IB}/{rxe,usnic}: Utilize generic mac to eui32
 function
Date: Tue, 25 Apr 2017 14:21:57 -0400
Message-ID: <1493144517.3041.83.camel@redhat.com>
References: <1489500117-7937-1-git-send-email-yuval.shaia@oracle.com>
         <20170314175843.GY2079@mtr-leonro.local> <20170424154612.GA2229@yuval-lap>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: benve-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, dgoodell-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170424154612.GA2229@yuval-lap>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-04-24 at 18:46 +0300, Yuval Shaia wrote:
> On Tue, Mar 14, 2017 at 07:58:43PM +0200, Leon Romanovsky wrote:
> > 
> > On Tue, Mar 14, 2017 at 04:01:57PM +0200, Yuval Shaia wrote:
> > > 
> > > This logic seems to be duplicated in (at least) three separate
> > > files.
> > > Move it to one place so code can be re-use.
> > > 
> > > Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > > ---
> > > v0 -> v1:
> > > 	* Add missing #include
> > > 	* Rename to genaddrconf_ifid_eui48
> > > v1 -> v2:
> > > 	* Reset eui[0] to default if dev_id is used
> > > v2 -> v3:
> > > 	* Add helper function to avoid re-setting eui[0] to default if
> > > 	  dev_id is used
> > > v3 -> v4:
> > > 	* Remove RXE wrappers
> > > 	* Remove addrconf_addr_eui48_xor and do the eui[0] ^= 2 in the
> > > 	  basic implementation
> > > ---
> > >  drivers/infiniband/hw/usnic/usnic_common_util.h | 11 +++-------
> > >  drivers/infiniband/sw/rxe/rxe.c                 |  4 +++-
> > >  drivers/infiniband/sw/rxe/rxe_loc.h             |  2 --
> > >  drivers/infiniband/sw/rxe/rxe_net.c             | 28 ---------
> > > ----------------
> > >  drivers/infiniband/sw/rxe/rxe_verbs.c           |  4 +++-
> > >  include/net/addrconf.h                          | 22
> > > +++++++++++++++----
> > >  6 files changed, 27 insertions(+), 44 deletions(-)
> > > 
> > 
> > Thanks, Yuval.
> > Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> Hi Doug,
> If no more comments on this one can you consider taking it?

It's applied, thanks.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
