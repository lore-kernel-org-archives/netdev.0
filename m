From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 07:29:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <46202575.1031297360@[10.10.2.3]>
References: <20020905.235159.128049953.davem@redhat.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020905.235159.128049953.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Stupid question, are you sure you have CONFIG_E1000_NAPI enabled?
> 
> NAPI is also not the panacea to all problems in the world.

No, but I didn't expect throughput to drop by 40% or so either,
which is (very roughly) what happened. Interrupts are a pain to
manage and do affinity with, so NAPI should (at least in theory)
be better for this kind of setup ... I think.
 
> I bet your greatest gain would be obtained from going to Tux
> and using appropriate IRQ affinity settings and making sure
> Tux threads bind to same cpu as device where they accept
> connections.
> 
> It is standard method to obtain peak specweb performance.

Ah, but that's not really our goal - what we're trying to do is
use specweb as a tool to simulate a semi-realistic customer
workload, and improve the Linux kernel performance, using that
as our yardstick for measuring ourselves. For that I like the
setup we have reasonably well, even though it won't get us the
best numbers.

To get the best benchmark numbers, you're absolutely right though.

M.
