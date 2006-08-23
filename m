From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 3/5] d80211: fix interface removal
Date: Wed, 23 Aug 2006 18:05:19 +0200
Message-ID: <20060823180519.77aacc82@griffin.suse.cz>
References: <20060822173241.313859000@devicescape.com>
	<20060822173353.GD12500@devicescape.com>
	<1156317628.3629.13.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:17043 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965000AbWHWQFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 12:05:21 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1156317628.3629.13.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006 09:20:28 +0200, Johannes Berg wrote:
> On Tue, 2006-08-22 at 10:33 -0700, David Kimdon wrote:
> > +	if (param->u.if_info.type == HOSTAP_IF_WDS) {
> > +		type = IEEE80211_IF_TYPE_WDS;
> > +	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
> > +		type = IEEE80211_IF_TYPE_VLAN;
> > +	} else if (param->u.if_info.type == HOSTAP_IF_BSS) {
> > +		type = IEEE80211_IF_TYPE_AP;
> > +	} else if (param->u.if_info.type == HOSTAP_IF_STA) {
> > +		type = IEEE80211_IF_TYPE_STA;
> > +	} else {
> > +        return -EINVAL;
> >  	}
> 
> IMHO that'd look better as a switch(). Or maybe even a small static
> array to map them and just some bounds checking code?

You're right, but I'm taking the patch anyway. It's resembling the code
of ieee80211_ioctl_add_if. Both of these function can be converted to
use switches later by one patch.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
