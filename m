From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v5] ss: Enclose IPv6 address in brackets
Date: Fri, 4 Aug 2017 12:05:06 -0700
Message-ID: <20170804120506.37c6ad60@xeon-e3>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
        <1aa882d5-b7f6-8b91-b884-0bd45ebeb2a2@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Lehner <dev@der-flo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:37564 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdHDTFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 15:05:09 -0400
Received: by mail-pg0-f46.google.com with SMTP id y129so11271211pgy.4
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 12:05:09 -0700 (PDT)
In-Reply-To: <1aa882d5-b7f6-8b91-b884-0bd45ebeb2a2@der-flo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Aug 2017 20:02:52 +0200
Florian Lehner <dev@der-flo.net> wrote:

> diff --git a/misc/ss.c b/misc/ss.c
> index 12763c9..83683b5 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1046,8 +1046,9 @@ do_numeric:
> 
>  static void inet_addr_print(const inet_prefix *a, int port, unsigned
> int ifindex)
>  {

Your email client is wrapping long lines which leads to malformed patch.

You didn't need buf2, and the code was more complex than it needed to be.

Rather than waiting for yet another version, I just merged in similar
code.
