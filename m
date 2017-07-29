From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ss: Enclose IPv6 address in brackets
Date: Sat, 29 Jul 2017 08:26:51 -0700
Message-ID: <20170729082651.1f959375@xeon-e3>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Lehner <dev@der-flo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35194 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752479AbdG2P04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 11:26:56 -0400
Received: by mail-pg0-f50.google.com with SMTP id v190so122110554pgv.2
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 08:26:56 -0700 (PDT)
In-Reply-To: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Jul 2017 14:29:10 +0200
Florian Lehner <dev@der-flo.net> wrote:

> This patch adds support for RFC2732 IPv6 address format with brackets
> for the tool ss. So output for ss changes from
> 2a00:1450:400a:804::200e:443 to [2a00:1450:400a:804::200e]:443 for IPv6
> addresses with attached port number.
> 
> Signed-off-by: Lehner Florian <dev@der-flo.net>
> ---

This is the right solution but it might break someone parsing the output of ss
command. Will apply it anyway unless someone has an objection.
