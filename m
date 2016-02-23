From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] net: vrf: Remove direct access to skb->data
Date: Tue, 23 Feb 2016 19:20:43 +0100
Message-ID: <56CCA2FB.1090309@cumulusnetworks.com>
References: <1456251026-21898-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34305 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808AbcBWSUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:20:46 -0500
Received: by mail-wm0-f54.google.com with SMTP id b205so4060737wmb.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 10:20:46 -0800 (PST)
In-Reply-To: <1456251026-21898-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2016 07:10 PM, David Ahern wrote:
> Nik pointed that the VRF driver should be using skb_header_pointer
> instead of accessing skb->data and bits beyond directly which can
> be garbage.
> 
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> Dave: This should go into v4.4 stable as well.
> 
>  drivers/net/vrf.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 

Thanks for the quick fix,

Fixes: 35402e313663 ("net: Add IPv6 support to VRF device")

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
