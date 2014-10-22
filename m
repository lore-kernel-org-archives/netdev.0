From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Wed, 22 Oct 2014 19:11:30 +0200
Message-ID: <CAKfDRXiOQK2Mc=OS26Pox-bpsca74uStm4RB5o5jKkhkD6d_5A@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
	<CAHA+R7OTmmeUf=_LaN1_isL1ZKiqcS0pYE0eKpRbPhaPeX-2jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:39995 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbaJVRLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 13:11:31 -0400
Received: by mail-yh0-f44.google.com with SMTP id i57so3821685yha.31
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 10:11:31 -0700 (PDT)
In-Reply-To: <CAHA+R7OTmmeUf=_LaN1_isL1ZKiqcS0pYE0eKpRbPhaPeX-2jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 22, 2014 at 6:56 PM, Cong Wang <cwang@twopensource.com> wrote:
> At least split TCP is transparent to applications, while your approach is not.
> I don't understand why you said it typically operates on some ports, since
> TCP is stateful.

I see that I might have used the wrong word here. I am use to calling
them TCP splitters, but I see that the devices are also referred to as
transparent TCP proxies. Anyhow, they are still transparent, but they
violate end-to-end (even though I guess that is pretty common
now-a-days).

What I mean by the port-comment is that only connections to some ports
are proxied/split. For example, one of the operators in Norway only
proxy port 80, so any HTTPS transfer risk getting stuck after a
temporary disconnect.

-Kristian
