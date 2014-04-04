From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: recompute the array size
Date: Fri, 4 Apr 2014 14:52:33 +0200
Message-ID: <20140404125233.GE13354@order.stressinduktion.org>
References: <1396594286-21788-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50848 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbaDDMwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 08:52:35 -0400
Content-Disposition: inline
In-Reply-To: <1396594286-21788-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 04, 2014 at 02:51:26PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> recompute the array size to kill the warning:
>  net/ipv6/xfrm6_state.c:66:26: error: cannot size expression

It is a sparse warning, no? sizeof in gcc has no problems with variable length
arrays.

Greetings,

  Hannes
