From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: Enable syn cookies by default
Date: Thu, 15 Oct 2009 10:59:03 +0200
Message-ID: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
References: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:56275 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934957AbZJOI7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 04:59:39 -0400
Received: by yxe17 with SMTP id 17so865944yxe.33
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 01:59:03 -0700 (PDT)
In-Reply-To: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2009 at 3:01 PM, Olaf van der Spek <olafvdspek@gmail.com> wrote:
> Hi,
>
> I'm forwarding Debian feature request #520668.
>
> Could syn cookies be enabled by default?
>
> AFAIK syn cookies only get send when the half-open TCP connection
> queue is full. So stuff like window scaling should work fine in normal
> situations.
>
> Speaking of which:
> When the half-open TCP connection queue is full and syn cookies are
> enabled, you get a message like "kernel: possible SYN flooding on port
> 2710. Sending cookies."
> However when syn cookies are disabled, you don't get any message (in
> kern.log), although connections to your server are timing out.
> Could such a message be added?
> Maybe with a suggestion to increase the size of that queue or to
> enable syn cookies.
>
> Greetings,
>
> Olaf
>
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=520668
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=520667
> https://bugs.launchpad.net/ubuntu/+bug/57091
>

Somebody?
