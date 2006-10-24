From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 07:02:12 -0700
Message-ID: <20061024140212.GB17543@devicescape.com>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:10382 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1161080AbWJXOCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 10:02:17 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Content-Disposition: inline
In-Reply-To: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> The following patches extend 802.11 regulatory domain support of the
> d80211 wireless stack through two modules:
> 
> 1. ieee80211_regdomains
> 2. iso3166-1

I am glad to see this work, this is something that we need a solution
for.  I do wonder if we can push most of this out of the kernel and
into userspace.  We could hard code a single set of constraints in the
kernel which may be used world wide (802.11b channels 1-11, is that
allowed everywhere?).  Then we have a userspace tool which passes
updated regulatory information into the kernel based on the user's
country input.

-David
