From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH 2/3] netlink: the temp variable name max is ambiguous
Date: Fri, 21 Sep 2007 00:56:35 +0800
Message-ID: <91b13c310709200956n155ff614p7234d28829a9b8ce@mail.gmail.com>
References: <1188675959178-git-send-email-crquan@gmail.com>
	 <11886759682348-git-send-email-crquan@gmail.com>
	 <20070916.163650.88475186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cr_quan@163.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:17098 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240AbXITQ4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 12:56:37 -0400
Received: by ug-out-1314.google.com with SMTP id z38so414581ugc
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 09:56:35 -0700 (PDT)
In-Reply-To: <20070916.163650.88475186.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/17/07, David Miller <davem@davemloft.net> wrote:
> From: Denis Cheng <crquan@gmail.com>
> Date: Sun,  2 Sep 2007 03:45:58 +0800
>
> > with the macro max provided by <linux/kernel.h>, so changed its name to a more proper one: limit
> >
> > Signed-off-by: Denis Cheng <crquan@gmail.com>
>
> Not strictly necessary because CPP knows to differentiate between
> 'max(' and plain 'max' when evaluating if a CPP macro should be
> expanded or not.
I also know the GNU CPP is intelligent, but people are often not.
I just think the avoidance to use human ambiguous names could give
more readability.

>
> Nonetheless, applied to net-2.6.24, thanks.
>

-- 
Denis Cheng
