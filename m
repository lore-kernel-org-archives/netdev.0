From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: Refactor: using new nl_msg struct for the all
 Netlink handlers
Date: Wed, 3 Sep 2014 18:33:49 -0700
Message-ID: <20140903183349.0209942d@urahara>
References: <1409777224-7813-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:59800 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbaIDBdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 21:33:55 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so18735393pab.28
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 18:33:54 -0700 (PDT)
In-Reply-To: <1409777224-7813-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 Sep 2014 23:47:04 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> It will easy to extend with new parameters in future.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Rather than go to all this effort, lets just convert iproute2 to use
a sane netlink library like libmnl.
