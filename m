From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] rfkill: remove rfkill-regulator
Date: Mon, 02 Jan 2017 16:03:56 +0100
Message-ID: <1483369436.21014.12.camel@sipsolutions.net>
References: <20170102150157.26745-1-johannes@sipsolutions.net>
         (sfid-20170102_160217_157310_15217E5D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Guiming Zhuo <gmzhuo@gmail.com>,
        Antonio Ospite <ospite@studenti.unina.it>,
        Paul Cercueil <paul@crapouillou.net>,
        Rob Herring <robh+dt@kernel.org>,
        Maarten ter Huurne <maarten@treewalker.org>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40404 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933053AbdABPD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Jan 2017 10:03:59 -0500
In-Reply-To: <20170102150157.26745-1-johannes@sipsolutions.net> (sfid-20170102_160217_157310_15217E5D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-02 at 16:01 +0100, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> There are no users of this ("vrfkill") in the tree, so it's just
> dead code - remove it.
> 
> This also isn't really how rfkill is supposed to be used - it's
> intended as a signalling mechanism to/from the device, which the
> driver (and partially cfg80211) will handle - having a separate
> rfkill instance for a regulator is confusing, the driver should
> use the regulator instead to turn off the device when requested.

OTOH, the rfkill-gpio is essentially the same thing, and it *does* get
used - by ACPI even, to control a GPS chip. And I'm not even sure that
there's a clear place to put this since there probably aren't any GPS
drivers?

johannes
