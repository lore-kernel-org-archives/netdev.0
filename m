From: Jeff Chua <jeffchua@silk.corp.fedex.com>
Subject: Re: [ANNOUNCE] iproute2 2.6.9-041019
Date: Wed, 20 Oct 2004 08:21:10 +0800 (SGT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410200805110.8475@boston.corp.fedex.com>
References: <41758014.4080502@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org, LARTC@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <41758014.4080502@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, 19 Oct 2004, Stephen Hemminger wrote:

> Now that 2.6.9 is final. Here is an update of the iproute2 utilities that


can't compile Got the following error. Linux is 2.6.9. Gcc is 2.95.3.


make[1]: Entering directory `/usr/src/net/iproute2-2.6.9/misc'
gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -g -I../include 
-DRESOLVE_HOSTNAMES   -c -o ss.o ss.c
In file included from /usr/include/asm/byteorder.h:57,
                  from ss.c:36:
/usr/include/linux/byteorder/little_endian.h:43: parse error before 
`__cpu_to_le64p'
/usr/include/linux/byteorder/little_endian.h: In function 
`__cpu_to_le64p':
/usr/include/linux/byteorder/little_endian.h:45: `__le64' undeclared 
(first use in this function)
/usr/include/linux/byteorder/little_endian.h:45: (Each undeclared 
identifier is reported only once
...

a lot of these errors.

These errors went away if linux-2.4.28pre4 is used to compile.


Thanks,
Jeff.
