From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol
 modules
Date: Thu, 01 May 2003 02:20:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501.022040.15235711.davem@redhat.com>
References: <5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
	<20030429.192931.104061911.davem@redhat.com>
	<1051726260.13512.59.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: maxk@qualcomm.com
In-Reply-To: <1051726260.13512.59.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Max Krasnyansky <maxk@qualcomm.com>
   Date: 30 Apr 2003 11:11:37 -0700

   And like I said before if protocol wants for some reason to be
   around until sk is destroyed it will simply do sk_set_owner() right
   after alloc_sk().

Ok Maxim, thanks for your comments and insight.

I believe this whole discussion is going to take a different
course towards a solution, different than anything discussed
in this thread so far.

Please follow the discussion with topic "dev->destructor" on this list
(netdev) to see precisely what I am talking about.
