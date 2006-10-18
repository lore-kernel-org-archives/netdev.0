From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 80211 questions
Date: Wed, 18 Oct 2006 15:29:38 +0200
Message-ID: <1161178178.5575.24.camel@ux156>
References: <19EFC4D481EBF849B14F91557CA737B54A6838@dile02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51385 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161010AbWJRN2q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 09:28:46 -0400
To: "Bar, Eitan" <eitanb@ti.com>
In-Reply-To: <19EFC4D481EBF849B14F91557CA737B54A6838@dile02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I'm working on adding WE (wireless extensions) support to a WLAN
> driver, and have recently bumped into references of nl80211, cfg80211
> and d80211.
> 
> My questions:
> - Can someone please shortly describe each term? 

d80211: wireless stack slated to replace the current ieee80211 subsystem
in the kernel, includes very advanced functionality and can drives
softmac chipsets like bcm43xx.

cfg80211: my proposal for the in-kernel wireless configuration interface
replacing WE

nl80211: tightly tied to cfg80211, this exports the cfg80211 interface
over netlink to userspace

There's also a compat interface so drivers can use cfg80211 but
userspace can continue to use WE.

> - Other than reading the source code and searching in news-groups, is
> there any serious source of information regarding any of the above?

not really, sorry. What specifically do you need? Also, what driver are
you adding support for? Could it make sense to make said driver use
d80211, or is it for a fullmac chipset?

> p.s: while I'm at it -> any good documentation on WE itself other than
> wireless.20.h ?

None as far as I know. Jean recommends reading the userspace tools
source code (which from my POV shows just /how/ broken WE is).

johannes
