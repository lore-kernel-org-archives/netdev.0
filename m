From: kuznet@ms2.inr.ac.ru
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 23:20:13 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211182020.XAA22559@sex.inr.ac.ru>
References: <20021118.121047.99725598.davem@redhat.com>
Mime-Version: 1.0
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20021118.121047.99725598.davem@redhat.com> from "David S. Miller" at Nov 18, 2 12:10:47 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> If not, the only thing which should get in the way is that there
> are two key managers registered but that should "just work" :)

At the moment km_acquire stops after the first manager accepts the acquisition.
Both of them always accept, so that guy how stands first in the list,
wins, another sees nothing.

Alexey
