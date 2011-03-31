From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Bridge: Removed unwanted check and improper usage of
 bridge locks
Date: Thu, 31 Mar 2011 08:36:02 -0700
Message-ID: <20110331083602.21946c50@nehalam>
References: <1301423072-28093-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Sasikanth V <sasikanth.v19@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45610 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758361Ab1CaPgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 11:36:07 -0400
In-Reply-To: <1301423072-28093-1-git-send-email-sasikanth.v19@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Mar 2011 23:54:32 +0530
Sasikanth V <sasikanth.v19@gmail.com> wrote:


I don't think this is needed because br_dev_open is already covered
by the netlink mutex RTNL
