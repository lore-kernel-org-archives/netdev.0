From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Fri, 9 Jan 2015 15:36:35 -0500
Message-ID: <CADVnQymucL99HvL4Tu79T502AiWJ3RQ-At93i3pthLTCqXuKPw@mail.gmail.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	<1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<54AEA498.5030202@uclouvain.be>
	<CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
	<1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:43315 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264AbbAIUgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 15:36:36 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so10859136qcr.0
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 12:36:36 -0800 (PST)
In-Reply-To: <CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 2:43 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Sebastien: I suggest breaking down by ACK types for readability. e.g.,

I like this approach, as well.  It breaks up the logic into smaller
pieces that are easier to comment and understand, without having
helper bool flags to read and mentally track. And this version passes
all our internal TLP tests, FWIW.

neal
