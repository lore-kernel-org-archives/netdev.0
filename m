From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 11:43:36 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906.114336.132077566.davem@redhat.com>
References: <20020906.113652.40767574.davem@redhat.com>
	<61557945.1031312716@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haveblue@us.ibm.com, ak@suse.de, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin.Bligh@us.ibm.com
In-Reply-To: <61557945.1031312716@[10.10.2.3]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
   Date: Fri, 06 Sep 2002 11:45:17 -0700

   >    Actually, oprofile separated out the acenic module from the rest of the 
   >    kernel.  I should have included that breakout as well. but it was only 1.3 
   >    of CPU:
   >    1.3801 0.0000 /lib/modules/2.4.18+O1/kernel/drivers/net/acenic.o
   > 
   > We thought you were using e1000 in these tests?
   
   e1000 on the server, those profiles were client side.
   
Ok.  BTW acenic is packet rate limited by the speed of the
MIPS cpus on the card.

It might be instramental to disable HW checksumming in the
acenic driver and see what this does to your results.
