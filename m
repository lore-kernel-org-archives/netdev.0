From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: asconf process should treat multiple address
 parameter as unrecognized parameter
Date: Tue, 25 Aug 2015 20:39:24 +0800
Message-ID: <CADvbK_c0=B5A66gqMRAg1x7iqUb7NFzs5roNW6fxHzexXovT6g@mail.gmail.com>
References: <13ab95079875febb3985b32d0fdaf587c6de1973.1440410850.git.lucien.xin@gmail.com>
	<55DB5939.8030902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	davem <davem@davemloft.net>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34262 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387AbbHYMjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 08:39:24 -0400
Received: by oiey141 with SMTP id y141so99407462oie.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 05:39:24 -0700 (PDT)
In-Reply-To: <55DB5939.8030902@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> I think it would be much better to catch this in the validation stage.
> If an implementation inserts multiple address parameters, we don't really know
> which one we should be using.
>

the params of ASCONF chunk should consist of one *Address Parameter* and one
or more *ASCONF Parameters*. besides, the address parameter should be in the
beginning. so the first one must be our choice.

if we cat this in the validation stage, I think it will be hard to treat it as a
unrecognized parameter,
