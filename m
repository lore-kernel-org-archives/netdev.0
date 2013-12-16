From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2 0/2] sctp: Consolidate and ratelimit deprecation warnings
Date: Mon, 16 Dec 2013 12:06:43 -0500
Message-ID: <1387213605-27206-1-git-send-email-nhorman@tuxdriver.com>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SCTP protocol has several deprecation warnings in its setsockopt path that
can be triggered by unprivlidged users.  Since these are not ratelimited, we can
spam the logs quite easily here.  Since these are all deprecation warnings, and
that type of warning isn't uncommon in the rest of the kernel, lets make a
common pr_warn_deprecated macro to produce somewhat generalized ratelimited
deprecation warnings easily

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: David Miller <davem@davemloft.net>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
