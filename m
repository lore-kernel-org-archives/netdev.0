From: Stefan Rompf <stefan@loplof.de>
Subject: Re: Suspending 802.11 drivers
Date: Thu, 22 Jun 2006 00:07:03 +0200
Message-ID: <200606220007.07467.stefan@loplof.de>
References: <200606152158.10079.mb@bu3sch.de> <200606162036.26518.stefan@loplof.de> <43e72e890606210808n187771e6k2f58789cf1fcf680@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from natklopstock.rzone.de ([81.169.145.174]:28111 "EHLO
	natklopstock.rzone.de") by vger.kernel.org with ESMTP
	id S1030315AbWFUWF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 18:05:56 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890606210808n187771e6k2f58789cf1fcf680@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch 21 Juni 2006 17:08 schrieb Luis R. Rodriguez:

> Since d80211 is already being patched for sysfs how about we use sysfs
> (and kobjects) to maintain the state at suspend() and resume(). This
> would allow userspace tools like supplicant running in the background
> to pick up from sysfs where it left off and for our drivers to save
> where we left off.

Forgive me that I'm so insistant on this question, but this is important: What 
state that goes beyond the data settable with wireless ioctls/iwconfig (that 
is kept anyway) needs to be saved by the stack? Last association info is 
worthless, the assocation can be restored using the ESSID/BSSID/channel set 
with iwconfig or by wpa_supplicant. Important is that userspace is notified 
about the connection loss. Is there _any_ other information not recreatable 
from iwconfig settings that needs to be kept?

Stefan
