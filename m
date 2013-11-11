From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 10:08:52 +0100
Message-ID: <1384160932.14334.6.camel@jlt4.sipsolutions.net>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	 (sfid-20131110_225237_639267_0727F79C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Felipe Contreras <felipe.contreras@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:35371 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab3KKJJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 04:09:02 -0500
In-Reply-To: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com> (sfid-20131110_225237_639267_0727F79C)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-11-10 at 15:45 -0600, Felipe Contreras wrote:
> We don't want to be waiting forever for a beacon that will never come,
> just continue the association.

This makes no sense, IMO.

If there really are no beacons at all, then nothing can work with the AP
-- things like HT, regulatory/radar, powersave, multiple virtual
interfaces and many others require beacons.

If the AP is sending beacons but the device isn't receiving them, then
it's a driver bug and mac80211 shouldn't work around it.

johannes
