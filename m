From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 14:33:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625.143334.85380461.davem@redhat.com>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	<1056547262.1945.1436.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, paulus@samba.org, netdev@oss.sgi.com,
   fcusack@samba.org, dfs@roaringpenguin.com, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mostrows@watson.ibm.com
In-Reply-To: <1056547262.1945.1436.camel@brick.watson.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Why don't you just queue the payload packets in a "resolution queue"
until the socket is created?  Just make the resolution queue packets
timeout using a value that will easily exceed any reasonable PPP
negotiation time.

All this ordered packet arrival shit is just beyond stupid.
