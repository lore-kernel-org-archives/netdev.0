From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Support SOCK_DESTROY in ss
Date: Tue, 17 Nov 2015 19:28:27 -0800
Message-ID: <20151117192827.4f7fcd48@samsung9>
References: <1447811530-10756-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	maze@google.com, dtor@google.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32983 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbbKRD2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 22:28:30 -0500
Received: by pabfh17 with SMTP id fh17so30744613pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 19:28:29 -0800 (PST)
In-Reply-To: <1447811530-10756-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Nov 2015 10:52:08 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

> This patch adds ss support for the SOCK_DESTROY operation just
> submitted to net-next: http://patchwork.ozlabs.org/patch/545843/ .
> It allows a user with CAP_NET_ADMIN to close sockets using
> "ss --kill".
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Obviously this patch will be held off until upstream accepts the
kernel functionality
