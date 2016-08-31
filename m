From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Wed, 31 Aug 2016 16:59:17 +0200
Message-ID: <fd8a8adf-957a-9669-f8fc-512ae8f24372@6wind.com>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
 <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: David Lebrun <david.lebrun@uclouvain.be>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37738 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934774AbcHaO7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 10:59:23 -0400
Received: by mail-wm0-f47.google.com with SMTP id i5so95003144wmg.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 07:59:23 -0700 (PDT)
In-Reply-To: <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/08/2016 à 17:52, David Lebrun a écrit :
[snip]
> +#define SEG6_VERSION_MAJOR	0
> +#define SEG6_VERSION_MINOR	30
nit: This kind of macros are not used anymore upstream. The git sha1 or the
linux version perfectly identifies the version.
