From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Does the kernel have a function to parse a text IPv6 address?
Date: Fri, 18 Aug 2017 11:37:03 -0700
Message-ID: <CAM_iQpWQVAnOrV6C+pD-hvNTxoRMQjt-rY1hJvws9=1WpNU80w@mail.gmail.com>
References: <30054.1503081121@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33156 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdHRShY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 14:37:24 -0400
Received: by mail-pg0-f44.google.com with SMTP id t3so41305639pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 11:37:24 -0700 (PDT)
In-Reply-To: <30054.1503081121@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 11:32 AM, David Howells <dhowells@redhat.com> wrote:
> Does the kernel have a function to parse a text IPv6 address of the form
> "x:y:..::z" and put it into a struct sockaddr_in6?
>

in6_pton() in net/core/utils.c.
