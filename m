From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol
 modules
Date: Tue, 29 Apr 2003 19:29:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429.192931.104061911.davem@redhat.com>
References: <20030428.222728.48508327.davem@redhat.com>
	<20030429065419.GN25361@conectiva.com.br>
	<5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, mostrows@speakeasy.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: maxk@qualcomm.com
In-Reply-To: <5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Max Krasnyansky <maxk@qualcomm.com>
   Date: Tue, 29 Apr 2003 13:05:08 -0700

   - Why do we have to bump module refcount for 'struct sock' with
     _default_ callbacks ?

Nothing says that just because a sock uses default callbacks, it can't
be referenced in other ways by the implementation module, for example
it can sit in the protocol hash tables and that by itself requires
a module reference.
