From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] remove an outdated reference to T/TCP
Date: Tue, 6 Dec 2011 15:00:13 -0800
Message-ID: <CAK6E8=cne1UbOEcZ6ZfsJw-=qwUsO=yMEi3LNNsTpM_5crv0fg@mail.gmail.com>
References: <20111206200005.836D529006DD@tardy> <20111206.151920.696192671128392379.davem@davemloft.net>
 <4EDE8B8B.2000907@hp.com> <20111206.164243.402402261622724566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60102 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394Ab1LFXAf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 18:00:35 -0500
Received: by ggnr5 with SMTP id r5so6853964ggn.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 15:00:34 -0800 (PST)
In-Reply-To: <20111206.164243.402402261622724566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 6, 2011 at 1:42 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> From: Rick Jones <rick.jones2@hp.com>
> Date: Tue, 06 Dec 2011 13:39:23 -0800
>
> > On 12/06/2011 12:19 PM, David Miller wrote:
> >> From: Rick Jones<rick.jones2@hp.com>
> >> Date: Tue, =A06 Dec 2011 12:00:05 -0800 (PST)
> >>
> >>>
> >>> Remove a particularly out of date bit of comment referring to T/T=
CP.
> >>>
> >>> Signed-off-by: Rick Jones<rick.jones2@hp.com>
> >>
> >> I think it should stay because it discusses the potential bad side
> >> effects of queueing any data that might be in the SYN.
> >
> > How about just the sentence that mentioned T/TCP explicitly since
> > T/TCP is most definitely no longer starting to be used?-) The rest =
of
> > it can be discussed when/if TCP Fast Open arrives :)
>
> T/TCP gives the statement context, as in referencing something that
> might make us want to at least theoretically consider handling the
> data.
I am fine keeping the comment as is.  This does remind me to put more
comments on this part of the code in our upcoming Fast Open patch :)
