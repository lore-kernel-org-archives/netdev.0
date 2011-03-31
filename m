From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bridge] [PATCH] bridge: return value for
 br_stp_recalculate_bridge_id()
Date: Thu, 31 Mar 2011 15:31:00 -0700
Message-ID: <20110331153100.44b02f86.akpm@linux-foundation.org>
References: <1301466207-16770-1-git-send-email-dongdong.deng@windriver.com>
	<20110331103822.39b1a89e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dongdong Deng <dongdong.deng@windriver.com>, <davem@davemloft.net>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40393 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751664Ab1CaWbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 18:31:02 -0400
In-Reply-To: <20110331103822.39b1a89e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Mar 2011 10:38:22 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> Reported 3 times and already fixed.

Four times!

Heaven knows why gcc treats that as a warning and not an error.  It's a
guaranteed runtime bug.

