From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH 1/2] mac80211: make max_network_latency notifier
 atomic safe
Date: Wed, 09 Jun 2010 11:38:07 +0200
Message-ID: <1276076287.3727.15.camel@jlt3.sipsolutions.net>
References: <1276074915-26879-1-git-send-email-florian@mickler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pm list <linux-pm@lists.linux-foundation.org>,
	james.bottomley@suse.de, markgross@thegnar.org,
	mgross@linux.intel.com,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Javier Cardona <javier@cozybit.com>, Jouni Malinen <j@w1.fi>,
	Rui Paulo <rpaulo@gmail.com>,
	Kalle Valo <kalle.valo@nokia.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: florian@mickler.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:50183 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757175Ab0FIJi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 05:38:26 -0400
In-Reply-To: <1276074915-26879-1-git-send-email-florian@mickler.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-09 at 11:15 +0200, florian@mickler.org wrote:
> In order to have the pm_qos framework be callable from interrupt
> context, all listeners have to also be callable in that context.

That makes no sense at all. Why add work structs _everywhere_ in the
callees and make the API harder to use and easy to get wrong completely,
instead of just adding a single work struct that will be queued from the
caller and dealing with the locking complexity etc. just once.

johannes

