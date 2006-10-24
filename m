From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 01:33:32 -0400
Message-ID: <43e72e890610232233t14ee98f6j5d5facf1b7aab08b@mail.gmail.com>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
	 <1161646361.3942.21.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:21647 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1752068AbWJXFde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 01:33:34 -0400
Received: by nf-out-0910.google.com with SMTP id c2so90480nfe
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2006 22:33:33 -0700 (PDT)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1161646361.3942.21.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/06, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Mon, 2006-10-23 at 18:41 -0400, Luis R. Rodriguez wrote:
>
> > The current setup on d80211.h makes regulatory domains device
> > specific. I believe this should be changed to be stack-specific --
> > that is, all drivers adhere to the restrictions set by the stack's
> > current regulatory domain.
>
> There should be a way to have a certain device restrict that even
> further, if the driver wants to allow operation only in a domain that
> the device has been certified for (because it may malfunction otherwise,
> for example).

Sure good idea -- we can provide a device specific regulatory domain
if necessary. We can easily introduce a device_regdomains linked list
on the ieee80211_conf which if not empty the driver will use it, else
the stack regdomain is used. The ieee80211_regdomains module already
provides the interfaces for the manipulation of such list. Pretty easy
fix, fortunately.

> I'll probably have more comments later, really tired now though.

Great, thanks.

  Luis
