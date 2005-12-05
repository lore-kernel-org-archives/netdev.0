From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 17:19:01 -0500
Message-ID: <4394BCD5.1060505@psc.edu>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com> <43947FEB.7020504@unfix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Singer <elf@buici.com>, Ben Greear <greearb@candelatech.com>,
	Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Jeroen Massar <jeroen@unfix.org>
In-Reply-To: <43947FEB.7020504@unfix.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeroen Massar wrote:
> I wonder how many RFC's it violates. An interface must only answer ARP's
> on the interface that it is configured on, not anything else.

Not true.  See RFC 1122, section 3.3.4.  The standard leaves this 
decision up to the implementation, for good reason.

 From 1122 (note the use of MAY, not MUST or SHOULD):
"
             There are two key requirement issues related to multihoming:

             (A)  A host MAY silently discard an incoming datagram whose
                  destination address does not correspond to the physical
                  interface through which it is received.

             (B)  A host MAY restrict itself to sending (non-source-
                  routed) IP datagrams only through the physical
                  interface that corresponds to the IP source address of
                  the datagrams.
"

This topic has been discussed many times on a variety of mailing lists. 
  I think the best way to do this is to make the behavior configurable, 
which Linux currently does.

   -John
