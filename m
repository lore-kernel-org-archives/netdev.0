From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: use oneshot blink API for LED triggers
Date: Thu, 01 Aug 2013 09:29:11 +0200
Message-ID: <1375342151.8608.0.camel@jlt4.sipsolutions.net>
References: <1374746426-22030-1-git-send-email-fabio.baltieri@gmail.com>
	 (sfid-20130725_120041_569594_897514BC)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Fabio Baltieri <fabio.baltieri@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:53893 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab3HAH3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 03:29:21 -0400
In-Reply-To: <1374746426-22030-1-git-send-email-fabio.baltieri@gmail.com> (sfid-20130725_120041_569594_897514BC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-25 at 12:00 +0200, Fabio Baltieri wrote:
> Change mac80211 LED trigger code to use the generic
> led_trigger_blink_oneshot() API for transmit and receive activity
> indication.
> 
> This gives a better feedback to the user, as with the new API each
> activity event results in a visible blink, while a constant traffic
> results in a continuous blink at constant rate.

Applied.

johannes
