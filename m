From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sat, 07 Dec 2002 15:45:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF28811.F6580BA6@digeo.com>
References: <3DF2781D.3030209@pobox.com> <20021207.144004.45605764.davem@redhat.com> <3DF27EE7.4010508@pobox.com> <3DF2844C.F9216283@digeo.com> <20021207233745.GE3183@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "J.A. Magallon" <jamagallon@able.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"J.A. Magallon" wrote:
> 
> #define __cacheline_start   struct { } ____cacheline_aligned;

That will generate a warning on faster^Wolder versions of gcc.

mnm:/home/akpm> gcc t2.c
t2.c:11: warning: unnamed struct/union that defines no instances
t2.c:15: warning: unnamed struct/union that defines no instances
mnm:/home/akpm> gcc -v 
Reading specs from /usr/local/lib/gcc-lib/i686-pc-linux-gnu/2.95.3/specs
gcc version 2.95.3 20010315 (release)
