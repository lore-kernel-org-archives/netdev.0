From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/6] bnx2x: link cleanup
Date: Wed, 20 Jun 2012 07:53:39 -0700
Message-ID: <1340204019.29885.9.camel@joe2Laptop>
References: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
	 <1340182175-916-3-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33207 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752074Ab2FTOxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 10:53:39 -0400
In-Reply-To: <1340182175-916-3-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 11:49 +0300, Yuval Mintz wrote:
> This patch does several things:
[]
>  3. Change msleep(1) --> usleep_range(1000, 1000)

I believe replacing msleep(small) with
usleep_range(small * 1000, small * 1000) is
not generally a good idea.

Please give usleep_range an actual range to
work with and not a repeated single value.

Please think a little more about what a
good upper range for the maximum time to
sleep should be.

usleep_range(small * 1000, small * 2000)
or something similar maybe.
