From: Isaac Boukris <iboukris@gmail.com>
Subject: Re: iproute: ss truncates abstract unix domain socket embedding null
Date: Sat, 29 Oct 2016 22:35:21 +0300
Message-ID: <CAC-fF8RzS1uYuYbs0xG5kUswH41EFKq7KEn1+HM8EjHNTapbEw@mail.gmail.com>
References: <CAC-fF8SMUsj8pPJO+VYdRSQAOcwyBpJY1C9V3VEk3zrFS=Jy4Q@mail.gmail.com>
 <CAC-fF8SdbDHPMZbOwHg=cOpsy+4ewTq9KGi-Cp=uaaG0hEJ8Fg@mail.gmail.com>
 <20161026101554.15d8d37b@xeon-e3> <CAC-fF8SuSWabeCW-nBUwn6VsgFyMfQF9s1f0XZhdjAgiSGzVTw@mail.gmail.com>
 <20161026152217.4058fcaa@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33014 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751586AbcJ2TfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 15:35:24 -0400
Received: by mail-lf0-f50.google.com with SMTP id m193so3912463lfm.0
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 12:35:23 -0700 (PDT)
In-Reply-To: <20161026152217.4058fcaa@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 1:22 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Just translating all null characters to @ seems the most consistent and
> logical. Also translating other all non-printing characters to something (maybe '?')
> might be wise. It would be nice if all utilities output the same thing.

I've sent two patches to netdev with which all of ss, netstat and lsof
would translate all null bytes the same way.
I left out the other non-printable characters as I wasn't as confident about it.

Thanks.
