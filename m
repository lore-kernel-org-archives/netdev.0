From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Patch 2.5.43] IpInDelivers, IpInDiscards
Date: Thu, 17 Oct 2002 15:24:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021017.152452.43031634.davem@redhat.com>
References: <Pine.LNX.4.44.0210171428520.3131-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <Pine.LNX.4.44.0210171428520.3131-100000@w-nivedita.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Thu, 17 Oct 2002 14:49:04 -0700 (PDT)

   This patch cleans up the use of the SNMP stats counters
   IpInDelivers and IpInDiscards (and the v6 counterparts). 
   A patch to address some of this had been submitted a while 
   ago by Mark Price.

I agree with with.  I just have some minor troubles with some of
the changes to ip_input.c

Specifically, the ip_rcv_finish() and ip_rcv() counter bumps
should all move to right below the drop: label which exists in
both functions.

Make this fixup, and I'll apply the patch.

Thanks.
