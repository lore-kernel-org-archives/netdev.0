From: "David S. Miller" <davem@redhat.com>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 12:23:07 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021118.122307.31019623.davem@redhat.com>
References: <20021118.121047.99725598.davem@redhat.com>
	<200211182020.XAA22559@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200211182020.XAA22559@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Mon, 18 Nov 2002 23:20:13 +0300 (MSK)
   
   At the moment km_acquire stops after the first manager accepts the acquisition.
   Both of them always accept, so that guy how stands first in the list,
   wins, another sees nothing.

Crap, indeed.

It should just keep sending to all key managers, right?
