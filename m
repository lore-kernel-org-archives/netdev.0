From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless notes / pre d80211 merge
Date: Wed, 15 Nov 2006 11:16:44 +0100
Message-ID: <1163585804.2705.44.camel@ux156>
References: <1163542797.5399.106.camel@johannes.berg>
	 <20061115011123.0eb1eff6@logostar.upir.cz> <1163582178.2705.16.camel@ux156>
	 <20061115110549.2fa3866c@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Daniel Drake <dsd@gentoo.org>, Hong Liu <hong.liu@intel.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Udayan Singh <udayan.singh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:5772 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966738AbWKOKPf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 05:15:35 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061115110549.2fa3866c@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-15 at 11:05 +0100, Jiri Benc wrote:

> I wasn't in times when there was no cfg80211. But now... yes, you're
> right. The sysfs ieee80211 class exports just some interesting
> informations (we already agreed that add_interface and remove_interface
> would go away). Feel free to move it wherever you think is appropriate.

Even with cfg80211 we have the wiphy concept embedded in there. Not much
difference because we still have to do tc on wmasterN and "wiconf" on
wiphyN. So that doesn't really change anything. Now, we could of course
drop the wiphy concept from cfg80211 easily and require doing all these
things on wmasterN. That's the option I considered in section (8). I
don't like it too much, but I think I could live with it.

johannes
