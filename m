From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/3] tcp: early retransmit: tcp_enter_recovery()
Date: Thu, 03 May 2012 03:56:59 +0200
Message-ID: <1336010219.22133.712.camel@edumazet-glaptop>
References: <1336001404-21879-1-git-send-email-ycheng@google.com>
	 <CADVnQymbDLXSR=aRB8SSd8GxpsFB3j2DLCBxH-1t2oS0T+sxgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, davem@davemloft.net,
	ilpo.jarvinen@helsinki.fi, nanditad@google.com,
	netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43193 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181Ab2ECB5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 21:57:05 -0400
Received: by wgbdr13 with SMTP id dr13so1245647wgb.1
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 18:57:04 -0700 (PDT)
In-Reply-To: <CADVnQymbDLXSR=aRB8SSd8GxpsFB3j2DLCBxH-1t2oS0T+sxgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 20:13 -0400, Neal Cardwell wrote:
> On Wed, May 2, 2012 at 7:30 PM, Yuchung Cheng <ycheng@google.com> wrote:
> > This a prepartion patch that refactors the code to enter recovery
> > into a new function tcp_enter_recovery(). It's needed to implement
> > the delayed fast retransmit in ER.
> >
> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> > ---
> > ChangeLog since v1:
> >  - swaped with part 1 and part2
> > ChangeLog since v2:
> >  - removed RFC in commit message
> > ChangeLog since v3:
> >  - nothing
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Yuchung, you should add our Acked-by to new submissions if no change on
a particular part was done, or else final inclusion wont have them

Acked-by: Eric Dumazet <edumazet@google.com>
