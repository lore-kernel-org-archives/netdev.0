From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Tue, 11 Aug 2009 20:24:59 -0700
Message-ID: <20090811202459.7f98e496@nehalam>
References: <1249985224.13065.11.camel@HunTEr>
	<1250035061.30166.42.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vibi_sreenivasan@cms.com, netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Thomas Graf <tgraf@suug.ch>,
	linux-next <linux-next@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1250035061.30166.42.camel@localhost.localdomain>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Aug 2009 16:57:41 -0700
Marcel Holtmann <marcel@holtmann.org> wrote:

> Hi Vibi,
> 
> > net/netlink/genetlink.c: In function `genl_register_mc_group':
> > net/netlink/genetlink.c:139: warning: 'err' might be used uninitialized in this function
> > 
> > Signed-off-by: vibi sreenivasan <vibi_sreenivasan@cms.com>
> > ---
> >  net/netlink/genetlink.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> > index 575c643..66f6ba0 100644
> > --- a/net/netlink/genetlink.c
> > +++ b/net/netlink/genetlink.c
> > @@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *family,
> >  {
> >         int id;
> >         unsigned long *new_groups;
> > -       int err;
> > +       int err = 0;
> >  
> >         BUG_ON(grp->name[0] == '\0');
> 
> this looks fishy. How does gcc thinks this variable is uninitialized. If
> I look at the code in Linus' tree, I don't see it.

Agreed, and the line numbers are off.

-- 
