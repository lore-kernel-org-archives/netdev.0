From: "David S. Miller" <davem@redhat.com>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 12:22:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021118.122241.93782164.davem@redhat.com>
References: <200211182004.XAA12908@sex.inr.ac.ru>
	<20021118.121047.99725598.davem@redhat.com>
	<20021118202229.GA22818@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl
In-Reply-To: <20021118202229.GA22818@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: bert hubert <ahu@ds9a.nl>
   Date: Mon, 18 Nov 2002 21:22:29 +0100

   Would you perhaps want to explain what CONFIG_XFRM_USER is going to be like?
   Netlink instead of PFKEY, but other notable things?

What you see in the code is what it will be like :-)

The only really mentionable thing is that when we notice that
PFKEY side has shit semantics, we will make netlink side saner :)

The only immediate difference is that with table dump operations
netlink queues where PFKEY does not.
