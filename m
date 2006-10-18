From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: Fix TX/RX rates
Date: Wed, 18 Oct 2006 17:42:28 +0200
Message-ID: <20061018174228.29843012@griffin.suse.cz>
References: <200610152014.08260.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John Linville" <linville@tuxdriver.com>,
	geromanas@mailas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:56195 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751205AbWJRPma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:42:30 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610152014.08260.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Oct 2006 20:14:07 +0200, Ivo van Doorn wrote:
> This patch correctly initializes the force_unicast_rateidx
> and max_ratectrl_rateidx. This was not done previously
> and caused a bug in rf80211_simple where when
> rate_control_simple_get_rate() was called, the incorrect
> rate was selected from the list.

Applied to my tree, thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs
