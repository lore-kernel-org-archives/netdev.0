From: "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>
Subject: Re: [PATCH 1/5] device property: helper macros for property entry creation
Date: Sat, 08 Aug 2015 00:08:19 +0200
Message-ID: <6986422.HLaTehgfKn@vostro.rjw.lan>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com> <1438783338.29746.172.camel@linux.intel.com> <20150806074848.GH7675@kuha.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150806074848.GH7675-FZxXFokcWpatqXYlAKuG4QC/G2K4zDHf@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday, August 06, 2015 10:48:48 AM Heikki Krogerus wrote:
> On Wed, Aug 05, 2015 at 05:02:18PM +0300, Andy Shevchenko wrote:
> > On Wed, 2015-08-05 at 16:39 +0300, Heikki Krogerus wrote:
> > > Marcos for easier creation of build-in property entries.
> > > 
> > > Signed-off-by: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > > ---
> > >  include/linux/property.h | 35 +++++++++++++++++++++++++++++++++++
> > >  1 file changed, 35 insertions(+)
> > > 
> > > diff --git a/include/linux/property.h b/include/linux/property.h
> > > index 76ebde9..204d899 100644
> > > --- a/include/linux/property.h
> > > +++ b/include/linux/property.h
> > > @@ -152,6 +152,41 @@ struct property_entry {
> > >  	} value;
> > >  };
> > >  
> > > +#define PROP_ENTRY_U8(_name_, _val_) { \
> > 
> > PROP_ prefix is too generic.
> > Maybe DEVPROP_ ? At least for the latter no records in the current
> > sources.
> 
> I disagree with that. IMO this kind of macros should ideally resemble
> the structure name they are used to fill (struct property_entry in
> this case). And there are already definitions for DEV_PROP_* to
> describe the types, so using something like DEVPROP_* here is just
> confusing.
> 
> If PROP_ENTRY_* is really not good enough, we can change them
> PROPERTY_ENTRY_*. But is PROP_ENTRY_* really so bad?
> 
> Rafael, what is your opinion?

I would prefer PROPERTY_ENTRY_ to be honest.  It's not like we need to save
characters here.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
