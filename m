From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 11:38:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906.113829.65591342.davem@redhat.com>
References: <3D78F55C.4020207@colorfullife.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haveblue@us.ibm.com, hadi@cyberus.ca, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: manfred@colorfullife.com
In-Reply-To: <3D78F55C.4020207@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Manfred Spraul <manfred@colorfullife.com>
   Date: Fri, 06 Sep 2002 20:35:08 +0200

   The second point was that interrupt mitigation must remain enabled, even 
   with NAPI: the automatic mitigation doesn't work with process space 
   limited loads (e.g. TCP: backlog queue is drained quickly, but the 
   system is busy processing the prequeue or receive queue)

Not true.  NAPI is in fact a %100 replacement for hw interrupt
mitigation strategies.  The cpu usage elimination afforded by
hw interrupt mitigation is also afforded by NAPI and even more
so by NAPI.
   
See Jamal's paper.

Franks a lot,
David S. Miller
davem@redhat.com
