From: Aristide Fattori <joystick@security.dico.unimi.it>
Subject: Re: Null pointer dereference in icmp_send
Date: Tue, 17 May 2011 09:31:28 +0200
Message-ID: <BANLkTinNeK1KVv8L-+ySgG-nfhg1=eiUPg@mail.gmail.com>
References: <BANLkTi=uBDOQOJJMGn6V0Ne7OjQ7kGc-2w@mail.gmail.com>
 <1305581236.9466.4.camel@edumazet-laptop> <1305581934.9466.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	roberto.paleari@emaze.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60204 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439Ab1EQHbt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 03:31:49 -0400
Received: by bwz15 with SMTP id 15so264438bwz.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 00:31:48 -0700 (PDT)
In-Reply-To: <1305581934.9466.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, May 16, 2011 at 11:38 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 16 mai 2011 =E0 23:27 +0200, Eric Dumazet a =E9crit :
>> You forgot to tell us which linux version you used ?

Sorry about that, we verified the bug in versions 2.6.38.3, 2.6.38.4
and 2.6.38.6, but we didn't check the svn version :-)

> ...
> But if a timeout occurs, we take first queued fragment to build one I=
CMP
> TIME EXCEEDED message. Problem is all queued skb have weak dst pointe=
rs,
> ...

At a first glance, it appears we identified the same bug you already
fixed. If you want to double check, we can send you the "long version
report" that we submitted at first to security@kernel.org and
david@davemloft.net.

> It is scheduled for linux-2.6.38 stable tree as well

Good job! :-)

--=20
GnuPG Key on keyserver.pgp.com ID 0x25578128
http://security.dico.unimi.it/~joystick/
