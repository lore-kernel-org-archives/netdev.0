From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2] tc: fix ipv6 filter selector attribute for
 some prefix lengths
Date: Sun, 1 Oct 2017 13:42:47 -0700
Message-ID: <20171001134247.59cc2e28@xeon-e3>
References: <20170927092634.0870468d@shemminger-XPS-13-9360>
        <20171001031840.1252538-1-hex@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yulia.kartseva@gmail.com>
To: Yulia Kartseva <hex@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:48375 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751755AbdJAUmz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 16:42:55 -0400
Received: by mail-pf0-f174.google.com with SMTP id n24so1994555pfk.5
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 13:42:55 -0700 (PDT)
In-Reply-To: <20171001031840.1252538-1-hex@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Sep 2017 20:18:40 -0700
Yulia Kartseva <hex@fb.com> wrote:

> Wrong TCA_U32_SEL attribute packing if prefixLen AND 0x1f equals 0x1f.
> These are  /31, /63, /95 and /127 prefix lengths.
> 
> Example:
> ip6 dst face:b00f::/31
> filter parent b: protocol ipv6 pref 2307 u32
> filter parent b: protocol ipv6 pref 2307 u32 fh 800: ht divisor 1
> filter parent b: protocol ipv6 pref 2307 u32 fh 800::800 order 2048
> key ht 800 bkt 0
>   match faceb00f/ffffffff at 24
> 
> v2: previous patch was made with a wrong repo
> 
> Signed-off-by: Yulia Kartseva <hex@fb.com>

That came through correctly. Applied.
