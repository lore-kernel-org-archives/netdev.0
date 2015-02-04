From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] bridge: Base the BR_PROXYARP decision on the target
 port flag
Date: Wed, 4 Feb 2015 15:13:59 -0800
Message-ID: <20150204151359.5f979f88@urahara>
References: <1423043467-11148-1-git-send-email-jouni@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kyeyoon Park <kyeyoonp@codeaurora.org>
To: Jouni Malinen <jouni@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:41796 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932873AbbBDXOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 18:14:01 -0500
Received: by pdiy13 with SMTP id y13so3668529pdi.8
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 15:14:00 -0800 (PST)
In-Reply-To: <1423043467-11148-1-git-send-email-jouni@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Feb 2015 11:51:05 +0200
Jouni Malinen <jouni@codeaurora.org> wrote:

> +		if (f && f->dst->flags & BR_PROXYARP)

Please add parens when mixing && and & in same if
