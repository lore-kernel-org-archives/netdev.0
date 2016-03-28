From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/3] tunnels: Don't apply GRO to multiple layers
 of encapsulation.
Date: Mon, 28 Mar 2016 15:33:13 -0400 (EDT)
Message-ID: <20160328.153313.379930780797175641.davem@davemloft.net>
References: <1458405122-12565-3-git-send-email-jesse@kernel.org>
	<CALx6S36Zw+ky+u0XHROV1AE21H=EU5=SEoAj7+AskxLw6b0Odg@mail.gmail.com>
	<CAEh+42hbYUMK4WMZYDtzfynd1XFb7OxKkmdPOdT1Z7=n-kw4sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: jesse@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbcC1TdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 15:33:15 -0400
In-Reply-To: <CAEh+42hbYUMK4WMZYDtzfynd1XFb7OxKkmdPOdT1Z7=n-kw4sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@kernel.org>
Date: Sun, 27 Mar 2016 21:38:34 -0700

> Generally speaking, multiple levels of encapsulation offload are not
> valid.

That's very much not true Jesse.

Please fix the regression you introduced or I will have no choice but to
revert your entire set of changes.
