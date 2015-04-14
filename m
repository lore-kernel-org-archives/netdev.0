From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/4] mac80211-hwsim: Pass rate-ctrl flags and tx-power
 to user-space
Date: Tue, 14 Apr 2015 10:15:45 +0200
Message-ID: <1428999345.3019.9.camel@sipsolutions.net>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
	 <1428095523-374-3-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54382 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbbDNIPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 04:15:47 -0400
In-Reply-To: <1428095523-374-3-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-03 at 14:12 -0700, greearb@candelatech.com wrote:

> +/* Auxilary info to allow user-space to better understand the rate */
> +struct hwsim_tx_rate2 {
> +	u16 rc_flags; /* rate-ctrl flags (see mac80211_rate_control_flags) */

I really don't like this - it ties internal API to userspace API. You
may argue that this is userspace that is for debug purposes only, but
I'm sure you'll also scratch your head very confused when I change the
rate control flags for any reason and your code breaks :)

johannes
