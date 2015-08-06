From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: Re: [PATCH 1/5] device property: helper macros for property entry
 creation
Date: Thu, 6 Aug 2015 10:48:48 +0300
Message-ID: <20150806074848.GH7675@kuha.fi.intel.com>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
 <1438781947-7952-2-git-send-email-heikki.krogerus@linux.intel.com>
 <1438783338.29746.172.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438783338.29746.172.camel@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 05, 2015 at 05:02:18PM +0300, Andy Shevchenko wrote:
> On Wed, 2015-08-05 at 16:39 +0300, Heikki Krogerus wrote:
> > Marcos for easier creation of build-in property entries.
> > 
> > Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> > ---
> >  include/linux/property.h | 35 +++++++++++++++++++++++++++++++++++
> >  1 file changed, 35 insertions(+)
> > 
> > diff --git a/include/linux/property.h b/include/linux/property.h
> > index 76ebde9..204d899 100644
> > --- a/include/linux/property.h
> > +++ b/include/linux/property.h
> > @@ -152,6 +152,41 @@ struct property_entry {
> >  	} value;
> >  };
> >  
> > +#define PROP_ENTRY_U8(_name_, _val_) { \
> 
> PROP_ prefix is too generic.
> Maybe DEVPROP_ ? At least for the latter no records in the current
> sources.

I disagree with that. IMO this kind of macros should ideally resemble
the structure name they are used to fill (struct property_entry in
this case). And there are already definitions for DEV_PROP_* to
describe the types, so using something like DEVPROP_* here is just
confusing.

If PROP_ENTRY_* is really not good enough, we can change them
PROPERTY_ENTRY_*. But is PROP_ENTRY_* really so bad?

Rafael, what is your opinion?


Thanks,

-- 
heikki
