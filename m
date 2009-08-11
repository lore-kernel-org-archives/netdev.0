From: vibi sreenivasan <vibi_sreenivasan@cms.com>
Subject: Re: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Tue, 11 Aug 2009 14:45:10 +0530
Message-ID: <1249982110.13065.7.camel@HunTEr>
References: <1249975630.2400.7.camel@HunTEr>
	 <1249976174.5903.16.camel@johannes.local>
Reply-To: vibi_sreenivasan@cms.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1249976174.5903.16.camel@johannes.local>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johannes,
On Tue, 2009-08-11 at 09:36 +0200, Johannes Berg wrote:
> On Tue, 2009-08-11 at 12:57 +0530, vibi sreenivasan wrote:
> > Fix following compiler warnings
> > 
> > net/netlink/genetlink.c: In function `genl_register_mc_group':
> > net/netlink/genetlink.c:139: warning: 'err' might be used uninitialized in this function
> 
> Well, only if there's no netns which can't happen.
	So how to silence that warning?
> 
> However, technical problems prohibit your patch from being applied.
> 
> a) you sent it to the wrong list, copying netdev
> 
Sorry i will send it to netdev

> > Signed-off-by: vibi sreenivasan, CMS COMPUTERS LTD, INDIA <vibi_sreenivasan@cms.com>
> 
> b) this isn't correctly formatted, have you actually read
> Documentation/SubmittingPatches including the legal text that you're
> agreeing to (section 12 of that document)?
> 
Sorry again i will remove the tags at the end & resubmit it again.

Thanks for pointing out the issues.

Thanks & Regards
vibi sreenivasan

> johannes
> 
> >  net/netlink/genetlink.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> > index 575c643..66f6ba0 100644
> > --- a/net/netlink/genetlink.c
> > +++ b/net/netlink/genetlink.c
> > @@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *family,
> >  {
> >  	int id;
> >  	unsigned long *new_groups;
> > -	int err;
> > +	int err = 0;
> >  
> >  	BUG_ON(grp->name[0] == '\0');
> >  
> 
