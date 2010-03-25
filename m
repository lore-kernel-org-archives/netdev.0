From: =?UTF-8?B?5p2o56GV?= <shanqn@gmail.com>
Subject: Re: why not use the tcp_set_state() in inet_csk_listen_start()?
Date: Thu, 25 Mar 2010 08:49:32 +0800
Message-ID: <ffe582101003241749j45add515u1e4c6bf11cfcacfc@mail.gmail.com>
References: <ffe582101003240113i15c48ff2g850bb209c825b11c@mail.gmail.com>
	 <1269421323.3213.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47311 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136Ab0CYAtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 20:49:35 -0400
Received: by wyb38 with SMTP id 38so3264374wyb.19
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 17:49:32 -0700 (PDT)
In-Reply-To: <1269421323.3213.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

But if we use "STATE_TRACE", maybe the state will be incomplete.

> Because its not necessary ?
>
> tcp_set_state() takes care of particular state transitions.
>
> In case of inet_csk_listen_start(), old state is TCP_CLOSE, so there is
> nothing special to do in tcp_set_state().
>
