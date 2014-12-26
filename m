From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [E1000-devel] [PATCH net v3 3/4] e1000e: Add netif_napi_del in
 the driver
Date: Fri, 26 Dec 2014 13:42:37 -0800
Message-ID: <20141226134237.7004c3c5@urahara>
References: <1419472623-6060-1-git-send-email-baijiaju1990@163.com>
	<1419472623-6060-3-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux.nics@intel.com
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:60171 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaLZVmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 16:42:50 -0500
Received: by mail-pd0-f175.google.com with SMTP id g10so13565488pdj.20
        for <netdev@vger.kernel.org>; Fri, 26 Dec 2014 13:42:49 -0800 (PST)
In-Reply-To: <1419472623-6060-3-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Dec 2014 09:57:02 +0800
Jia-Ju Bai <baijiaju1990@163.com> wrote:

> The driver lacks netif_napi_del in the normal path
> and error path to match the call of netif_napi_add in e1000_probe.
> This patch fixes this problem, and it has been tested on the hardware.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Another case where netif_napi_del is not needed since already
handled by free_netdev
