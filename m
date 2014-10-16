From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] vxlan: small improvements
Date: Thu, 16 Oct 2014 15:05:04 +0200
Message-ID: <20141016150504.59db62b5@uryu.home.lan>
References: <1413450045-5008-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:64091 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaJPNFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 09:05:22 -0400
Received: by mail-wg0-f49.google.com with SMTP id x12so3684284wgg.8
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 06:05:20 -0700 (PDT)
In-Reply-To: <1413450045-5008-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Oct 2014 17:00:44 +0800
roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 1. remove the dead codes, pr_fmt definition and vxlan_salt variable
> 2. pskb_may_pull() can change skb->data, so we have to reload eth in vxlan_xmit.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

You are doing 4 things in one patch.

The pr_fmt definition is standard way to identify where log messages orginate
