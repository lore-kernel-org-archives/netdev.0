From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] bridge: call br_netpoll_disable in br_add_if
Date: Thu, 20 Dec 2012 18:33:33 +0800
Message-ID: <1355999613.25310.11.camel@cr0>
References: <1355996503-19318-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab2LTKdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 05:33:47 -0500
In-Reply-To: <1355996503-19318-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 17:41 +0800, Gao feng wrote:
> When netdev_set_master faild in br_add_if, we should
> call br_netpoll_disable to do some cleanup jobs,such
> as free the memory of struct netpoll which allocated
> in br_netpoll_enable.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Looks good!

Acked-by: Cong Wang <amwang@redhat.com>
