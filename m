From: Adrian Bunk <bunk@fs.tum.de>
Subject: 2.6: rxrpc compile errors with SYSCTL=n
Date: Thu, 12 Aug 2004 00:32:25 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040811223225.GN26174@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268281AbUHKWch@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

I'm getting tons of the following compile errors in 2.6.8-rc4-mm1 (but 
it doesn't seem to be specific to -mm) with CONFIG_SYSCTL=n:

<--  snip  -->

...
  LD      .tmp_vmlinux1
net/built-in.o(.text+0x154127): In function `__rxrpc_call_acks_timeout':
: undefined reference to `rxrpc_kdebug'
net/built-in.o(.text+0x154167): In function `__rxrpc_call_rcv_timeout':
: undefined reference to `rxrpc_kdebug'
net/built-in.o(.text+0x1541a7): In function `__rxrpc_call_ackr_timeout':
: undefined reference to `rxrpc_kdebug'
net/built-in.o(.text+0x15421e): In function `rxrpc_create_call':
: undefined reference to `rxrpc_ktrace'
net/built-in.o(.text+0x154242): In function `rxrpc_create_call':
: undefined reference to `rxrpc_ktrace'
net/built-in.o(.text+0x154272): In function `rxrpc_create_call':
: undefined reference to `rxrpc_ktrace'
...
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
