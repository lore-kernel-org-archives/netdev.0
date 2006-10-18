From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: 80211 questions
Date: Wed, 18 Oct 2006 15:50:41 +0200
Message-ID: <1161179441.5575.31.camel@ux156>
References: <19EFC4D481EBF849B14F91557CA737B54A6839@dile02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:11236 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030269AbWJRNto
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 09:49:44 -0400
To: "Bar, Eitan" <eitanb@ti.com>
In-Reply-To: <19EFC4D481EBF849B14F91557CA737B54A6839@dile02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-18 at 15:45 +0200, Bar, Eitan wrote:

> [Eitan Bar] I was actually looking for any kind of design document, or
> anything related to the concept behind it.

As for cfg80211/nl80211 it was mostly discussed here on netdev and I
haven't written up anything.

> I'm adding WE support for a Texas Instruments driver for future
> chipsets. The driver is, at the moment, entirely proprietary (including
> user-mode API).

Heh, ok. I'm just wondering whether it would make sense for you to
provide a d80211 driver for that chipset instead. If you could tell me
(even in private if you wish) some details about what your hardware does
in firmware and what it does in the driver, I could help you make that
decision.

> [Eitan Bar] I see. Can you please point out if there's any driver
> currently supporting cfg80211 or nl80211 for reference? (which one are
> you using for testing?)

I have provided some code (very little actually) to make d80211 use
cfg80211 (and you can't do much with nl80211 yet), but no driver
implements it yet directly.

johannes
