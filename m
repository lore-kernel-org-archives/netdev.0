From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC iproute2 v2] tc: Show classes in tree view
Date: Sun, 21 Dec 2014 09:59:46 -0800
Message-ID: <20141221095946.73edf34a@urahara>
References: <1419155245-22535-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:51141 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbaLUR74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 12:59:56 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so4418410pdi.21
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 09:59:56 -0800 (PST)
In-Reply-To: <1419155245-22535-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 21 Dec 2014 11:47:25 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> +				INIT_HLIST_NODE(c);
> +				hlist_add_head(c, &childs);

Since hlist_add_head sets both c->next and c->pprev, the new INIT_HLIST_NODE()
is unnecessary.
