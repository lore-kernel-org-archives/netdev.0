From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 23:03:32 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030608.230332.48514434.davem@redhat.com>
References: <20030608.224446.78724665.davem@redhat.com>
	<001501c32e4b$35d67d60$4a00000a@badass>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: xerox@foonet.net
In-Reply-To: <001501c32e4b$35d67d60$4a00000a@badass>
List-Id: netdev.vger.kernel.org

   From: "CIT/Paul" <xerox@foonet.net>
   Date: Mon, 9 Jun 2003 01:51:45 -0400

   I'd love to test this out.. If it could do full gigabit line rate with
   random ips that would be soooooooo nice :>

It isn't impossible with the current design, that I am
quire sure of.

Here is a simple idea, make the routing cache miss case steal
an entry sitting at the end of the hash chain this new one will
map to.  It only steals entries which have not been recently used.

The big problem area on SMP is fib_validate_source.  I'm sure some
clear thinking can wipe that off the profiles too.
