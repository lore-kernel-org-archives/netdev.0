From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 05 Sep 2002 21:17:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020905.211703.38779558.davem@redhat.com>
References: <1031283490.3d7823228d9ed@imap.linux.ibm.com>
	<20020905.205842.127265672.davem@redhat.com>
	<1031286047.3d782d1f27162@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <1031286047.3d782d1f27162@imap.linux.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Thu,  5 Sep 2002 21:20:47 -0700
   
   Sure :). The motivation for seeing the stats though would
   be to get an idea of how much retransmission/SACK etc 
   activity _is_ occurring during Troy's SpecWeb runs, which
   would give us an idea of how often we're actually doing
   segmentation offload, and better idea of how much gain
   its possible to further get from this(ahem) DMA coalescing :).
   Some of Troy's early runs had a very large number of
   packets dropped by the card.

One thing to do is make absolutely sure that flow control is
enabled and supported by all devices on the link from the
client to the test spedweb server.

Troy can do you do that for us along with the statistic
dumps?

Thanks.
