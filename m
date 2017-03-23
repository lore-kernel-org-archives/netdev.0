From: Daurnimator <quae@daurnimator.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Thu, 23 Mar 2017 13:22:28 +1100
Message-ID: <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33794 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdCWC3i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:29:38 -0400
Received: by mail-io0-f181.google.com with SMTP id b140so74859529iof.1
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 19:29:37 -0700 (PDT)
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com. [209.85.223.180])
        by smtp.gmail.com with ESMTPSA id t90sm1736164ioi.31.2017.03.22.19.22.28
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 19:22:29 -0700 (PDT)
Received: by mail-io0-f180.google.com with SMTP id b140so74791420iof.1
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 19:22:28 -0700 (PDT)
In-Reply-To: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 March 2017 at 14:10, Daurnimator <quae@daurnimator.com> wrote:
> When debugging https://github.com/daurnimator/lua-http/issues/73 which
> uses https://github.com/wahern/dns we ran into an issue where modern
> linux kernels return EINVAL if you try and re-use a udp socket.
> The issue seems to occur if you go from a local destination ip to a
> non-local one.

Did anyone get a chance to look into this issue?
