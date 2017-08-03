From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4] ss: Enclose IPv6 address in brackets
Date: Thu, 3 Aug 2017 15:54:21 -0700
Message-ID: <20170803155421.482fd158@xeon-e3>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
        <821a72fb-3758-8a44-2b1e-727a73208e14@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Lehner <dev@der-flo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:37365 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdHCWyY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:54:24 -0400
Received: by mail-pg0-f52.google.com with SMTP id y129so368899pgy.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 15:54:23 -0700 (PDT)
In-Reply-To: <821a72fb-3758-8a44-2b1e-727a73208e14@der-flo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Aug 2017 18:54:33 +0200
Florian Lehner <dev@der-flo.net> wrote:

> -	if (a->family == AF_INET) {
> -		if (a->data[0] == 0) {
> +	if (a->data[0] == 0) {
>  			buf[0] = '*';
>  			buf[1] = 0;

This won't work right with IPv6 you need to look at the whole address being 0
not just a->data[0]
