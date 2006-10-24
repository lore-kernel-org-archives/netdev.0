From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 13:47:50 -0400
Message-ID: <43e72e890610241047g119a4ef5h95969941aa4a80ed@mail.gmail.com>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
	 <20061024140212.GB17543@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:29816 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1161115AbWJXRrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 13:47:52 -0400
Received: by wr-out-0506.google.com with SMTP id i4so381804wra
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 10:47:51 -0700 (PDT)
To: "David Kimdon" <david.kimdon@devicescape.com>
In-Reply-To: <20061024140212.GB17543@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, David Kimdon <david.kimdon@devicescape.com> wrote:
> Hi,
>
> > The following patches extend 802.11 regulatory domain support of the
> > d80211 wireless stack through two modules:
> >
> > 1. ieee80211_regdomains
> > 2. iso3166-1
>
> I am glad to see this work, this is something that we need a solution
> for.  I do wonder if we can push most of this out of the kernel and
> into userspace.  We could hard code a single set of constraints in the
> kernel which may be used world wide (802.11b channels 1-11, is that
> allowed everywhere?).

Unforunatley there is no easy middle ground that will make everyone
happy. What I defined as World is there just as most devices seem to
have such regulatory domain and what I defined it as is a compromise
in what seems to be the middle of all restrictions. There is no easy
answer here but I think the best is to consider that there is just no
"World" regulatory domain unless all regulatory domain agencies do
come up with one. We should see if legal can work with a few
regulatory agencies to see if at least a few will agree on one...

> Then we have a userspace tool which passes
> updated regulatory information into the kernel based on the user's
> country input.

Please see my more thorough reply to Johannes as he asked this first.
But yes -- you are right. The main reason why this has been put in the
kernel was to make a userspace daemon optional as it would allow us to
easily introduce regulatory domain control without forcing
distributions to use a new daemon immediately. Also we need to iron
out userspace communication before even considering a userspace
regulatory daemon. Keep in mind the Kconfig makes the regulatory
domains defined optional except World compliant regulatory domain
already.

  Luis
