From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 37/39] net/mac80211: Update WARN uses
Date: Sun, 31 Oct 2010 08:33:01 +0100
Message-ID: <1288510381.3839.0.camel@jlt3.sipsolutions.net>
References: <cover.1288471897.git.joe@perches.com>
	 <de75963e04701e309b86dfee54c36e11873048c2.1288471898.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <trivial@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:56660 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab0JaHdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 03:33:14 -0400
In-Reply-To: <de75963e04701e309b86dfee54c36e11873048c2.1288471898.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-10-30 at 14:08 -0700, Joe Perches wrote:
> Coalesce long formats.
> Add missing newlines.

> -			WARN(1, "frame for unexpected interface type");
> +			WARN(1, "frame for unexpected interface type\n");

But I thought WARN() added a newline...

johannes

