From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically
 configured
Date: Thu, 12 Feb 2015 04:55:58 -0800
Message-ID: <20150212045558.5091262a@uryu.home.lan>
References: <1423719323-4667-1-git-send-email-Yanjun.Zhu@windriver.com>
	<1423719323-4667-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mst@redhat.com>, <jasowang@redhat.com>,
	<viro@zeniv.linux.org.uk>, <davem@davemloft.net>
To: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:44543 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbbBLM4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 07:56:03 -0500
Received: by iecar1 with SMTP id ar1so11484595iec.11
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 04:56:02 -0800 (PST)
In-Reply-To: <1423719323-4667-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Feb 2015 13:35:23 +0800
Zhu Yanjun <Yanjun.Zhu@windriver.com> wrote:

> From: Zhu Yanjun <yanjun.zhu@windriver.com>
> 
> The default speed of normal nic is 1000M while the default speed
> of tun is 10M. Now the default speed of tun is changed to 1000M.
> And there are 3 options: 10M, 100M and 1000M to the speed of tun.
> The command "ethtool -s tun0 speed 10/100/1000" can configure the
> speed of tun dynamically.
> 
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> CC: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

Why limit to 10/100/1000 speed?
Ethtool speed can be any value

>  
