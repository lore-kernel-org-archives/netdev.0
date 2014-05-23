From: Cong Wang <cwang@twopensource.com>
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Fri, 23 May 2014 15:39:55 -0700
Message-ID: <CAHA+R7OkR_M9T51Y3zQa2QG3Rq1edJjT0SoMoaoD2tkyefnm4A@mail.gmail.com>
References: <6zlhtsvnqp.fsf@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: =?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:61087 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbaEWWj4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 18:39:56 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so9171399qgf.35
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 15:39:55 -0700 (PDT)
In-Reply-To: <6zlhtsvnqp.fsf@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 23, 2014 at 2:38 AM, Niels M=C3=B6ller <nisse@southpole.se>=
 wrote:
> Hi,
=2E...
>
> So now I'm trying to figure out what's the Right Way to enable traffi=
c
> generations with a large number of source addresses, to possibly reti=
re
> the proprietary kernel module. I see a couple of different approaches=
:
>
>

Isn't pktgen is what you are looking for? It provides src_min and src_m=
ax
to specify the range of source IPv4 addresses. But it does't understand
TCP, only UDP.
