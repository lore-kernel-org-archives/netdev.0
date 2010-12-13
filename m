From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH net-next-2.6] net: add dev_close_many
Date: Mon, 13 Dec 2010 19:52:39 +0200
Message-ID: <201012131952.39648.opurdila@ixiacom.com>
References: <1292249903-3865-1-git-send-email-opurdila@ixiacom.com> <201012131923.27337.opurdila@ixiacom.com> <20101213093221.5d941493@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"Lucian Adrian Grijincu" <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:2820 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756613Ab0LMRwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 12:52:41 -0500
In-Reply-To: <20101213093221.5d941493@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Monday 13 December 2010, 19:32:21

> With a message based interface, there shouldn't be a need for this.
> Just have one thread sending requests in user space, and one receiving
> the ACK's.

Sorry, you lost me here :) There is no need for the kernel thread / workqueue 
or not even for dev_close_many?
