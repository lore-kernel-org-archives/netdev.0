From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 08:03:10 -0400
Message-ID: <20061024120303.GB30724@tuxdriver.com>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com> <1161646361.3942.21.camel@johannes.berg> <43e72e890610232233t14ee98f6j5d5facf1b7aab08b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:63250 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1160995AbWJXMKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 08:10:15 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Content-Disposition: inline
In-Reply-To: <43e72e890610232233t14ee98f6j5d5facf1b7aab08b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2006 at 01:33:32AM -0400, Luis R. Rodriguez wrote:
> On 10/23/06, Johannes Berg <johannes@sipsolutions.net> wrote:
> >On Mon, 2006-10-23 at 18:41 -0400, Luis R. Rodriguez wrote:
> >
> >> The current setup on d80211.h makes regulatory domains device
> >> specific. I believe this should be changed to be stack-specific --
> >> that is, all drivers adhere to the restrictions set by the stack's
> >> current regulatory domain.
> >
> >There should be a way to have a certain device restrict that even
> >further, if the driver wants to allow operation only in a domain that
> >the device has been certified for (because it may malfunction otherwise,
> >for example).
> 
> Sure good idea -- we can provide a device specific regulatory domain
> if necessary. We can easily introduce a device_regdomains linked list
> on the ieee80211_conf which if not empty the driver will use it, else
> the stack regdomain is used. The ieee80211_regdomains module already
> provides the interfaces for the manipulation of such list. Pretty easy
> fix, fortunately.

It might be nice if this could be a "logical AND" operation?  So if the
device was certified for X, Y, and Z and the current domain allows V,
W, and X then only X would be allowed.  Perhaps it is too complicated
to be worthwhile, but it seems doable and would be a nice flexibility.

John
-- 
John W. Linville
linville@tuxdriver.com
