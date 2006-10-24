From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 13:31:26 -0400
Message-ID: <43e72e890610241031q41e7303bgb63786995f5c28d6@mail.gmail.com>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
	 <1161678344.2840.2.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:55529 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030449AbWJXRbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 13:31:38 -0400
Received: by ug-out-1314.google.com with SMTP id 32so271258ugm
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 10:31:26 -0700 (PDT)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1161678344.2840.2.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, Johannes Berg <johannes@sipsolutions.net> wrote:
> Alright, here's more now that I can think clearly again :)
>
> > ISO 3166-1, as part of the ISO 3166 standard, provides codes for the names
> > of countries and dependent areas. It was first published in 1974 by
> > the International Organization for Standardization (ISO) and defines three
> > different codes for each area:
> >
> >     * ISO 3166-1 alpha-2, a two-letter system with many applications,
> >       most notably the Internet top-level domains (ccTLD) for countries.
> >     * ISO 3166-1 alpha-3, a three-letter system.
> >     * ISO 3166-1 numeric, a three-digit numerical system, which is
> >     identical to that defined by the United Nations Statistical Division.
> >
> > Although this would usually be only used in userspace IEEE-802.11d
> > has made use of ISO-3166-1 alpha 3. This mapping was added
> > to enhance stack support for IEEE-802.11d and 802.11 Regulatory
> > Domain control. ieee80211_regdomains makes use of this module
> > by creating a map of iso3166 alpha3 country code to stack
> > regulatory domain.
>
> But if 802.11d only requires alpha 3, why put all the other stuff into
> the kernel as well?

It would have been a half ass job for kernel iso3166-1 support, also
though -- I feel we should leave this as-is until we have an ironed
out userspace regulatory daemon. This would make regulatory
domain/802.11d/MLME daemon optional to introduce for distributions
until that part is done and distributions have happily adopted
something. Since its a complete iso3166-1 db I wondered if any other
modules would make use of it. An example of a similar db in the kernel
is for Native Language Support (NLS) for filesystems. If no modules
can make use of it the quicker this should be removed once we have a
userspace API ready.

CC'ing LKML to see if any other module can make use of this.

  Luis
