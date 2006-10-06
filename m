From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Latest fixes to bcm43xx-d80211 now available as patch to 2.6.18
Date: Fri, 06 Oct 2006 10:30:26 +0200
Message-ID: <1160123426.2715.12.camel@ux156>
References: <45259659.9040804@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bcm43xx-dev@lists.berlios.de, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51384 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751271AbWJFI3x
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 04:29:53 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <45259659.9040804@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-10-05 at 18:33 -0500, Larry Finger wrote:

> The patch file contains Michael Buesch's changes of 05-Oct-2006. This
> version can use either V3 or V4 firmware. It has been compiled and
> tested on my system.

Note that there seem to be some problems with v4 firmware, I had the
machine hang at about 20% si/hi load with v4, maybe some interrupt the
v4 firmware keeps triggering and we never handle the condition or
something... I'll keep digging.

johannes
