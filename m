From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v3] e1000: Add netif_napi_del in the driver
Date: Fri, 26 Dec 2014 13:39:40 -0800
Message-ID: <20141226133940.2cd4752a@urahara>
References: <1419472827-6170-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:39417 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaLZVjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 16:39:54 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so13683906pad.23
        for <netdev@vger.kernel.org>; Fri, 26 Dec 2014 13:39:53 -0800 (PST)
In-Reply-To: <1419472827-6170-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Dec 2014 10:00:27 +0800
Jia-Ju Bai <baijiaju1990@163.com> wrote:

> The driver lacks netif_napi_del in the normal path 
> and error path to match the call of netif_napi_add in e1000_probe.
> This patch fixes this problem, and it has been tested on the hardware.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

This is unnecessary patch.
netif_napi_del is already called by free_netdev in the error path.
