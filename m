From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: ip fragments sent in reverse order?
Date: Fri, 27 May 2011 08:20:02 +0800
Message-ID: <BANLkTimTLoJkmD77NGcdgRaayT+Uj06YpA@mail.gmail.com>
References: <4DDE5BF9.6090508@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35431 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503Ab1E0AUX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 20:20:23 -0400
Received: by bwz15 with SMTP id 15so859806bwz.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 17:20:22 -0700 (PDT)
In-Reply-To: <4DDE5BF9.6090508@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2011 at 9:56 PM, Chris Friesen
<chris.friesen@genband.com> wrote:
>
> I read that Linux intentionally sends IP fragments in reverse order t=
o allow
> for some optimization on the receive side. =A0I'm trying to find this=
 code,
> but what I see in ip_fragment() seems to be creating/sending the frag=
ments
> in order. =A0Has this changed over the years?
>

Yes. Now the fragments are sent in order.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
