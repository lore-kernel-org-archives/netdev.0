From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] mlxsw: core: Use devm_kzalloc to allocate
 mlxsw_hwmon structure
Date: Tue, 22 Dec 2015 09:10:32 +0100
Message-ID: <20151222081032.GA2185@nanopsycho.orion>
References: <1450710726-3633-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37214 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbbLVIKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 03:10:34 -0500
Received: by mail-wm0-f53.google.com with SMTP id p187so99724409wmp.0
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 00:10:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1450710726-3633-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 21, 2015 at 04:12:06PM CET, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>KASan reported use-after-free for the hwmon structure. So fix this by
>using devm_kzalloc and let the core take care about freeing the memory
>during device dettach.

We found one small change is needed to be added. Will send v2.
