From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Wed, 28 Jun 2017 10:11:12 -0600
Message-ID: <20170628161112.GB28839@obsidianresearch.com>
References: <20170626182924.GB16026@obsidianresearch.com>
 <20170626192103.GH1248@mtr-leonro.local>
 <20170626203610.GB17892@obsidianresearch.com>
 <20170627040604.GI1248@mtr-leonro.local>
 <20170627092129.GR1248@mtr-leonro.local>
 <20170627164150.GA4288@obsidianresearch.com>
 <20170627173301.GS1248@mtr-leonro.local>
 <20170627173735.GA5162@obsidianresearch.com>
 <20170627174615.GV1248@mtr-leonro.local>
 <20170627151859.524d1079@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170627151859.524d1079@xeon-e3>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2017 at 03:18:59PM -0700, Stephen Hemminger wrote:
> On Tue, 27 Jun 2017 20:46:15 +0300
> Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> 
> > On Tue, Jun 27, 2017 at 11:37:35AM -0600, Jason Gunthorpe wrote:
> > > On Tue, Jun 27, 2017 at 08:33:01PM +0300, Leon Romanovsky wrote:
> > >  
> > > > My initial plan was to put all parsers under their respective names, in
> > > > the similar way as I did for caps: $ rdma dev show mlx5_4 caps  
> > >
> > > I think you should have a useful summary display similar to 'ip a' and
> > > other commands.
> > >
> > > guid(s), subnet prefix or default gid for IB, lid/lmc, link state,
> > > speed, mtu, pkeys protocol(s)  
> > 
> > It will, but before I would like to see this tool be a part of
> > iproute2, so other people will be able to extend it in addition
> > to me.
> > 
> > Are you fine with the proposed code?
> > 
> 
> Output formats need to be nailed down. The output of iproute2 commands is almost
> like an ABI. Users build scripts to parse it (whether that is a great idea or not
> is debateable, it mostly shows the weakness in programatic API's). Therefore fully
> changing output formats in later revisions is likely to get users upset.

It would be nice to see an example of what the completed command
should output to make judgements on the format.. Going bit by bit
doesn't really give a full picture, IHO.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
