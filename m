From: "David S. Miller" <davem@redhat.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 18:00:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020917.180014.07882539.davem@redhat.com>
References: <3D87A59C.410FFE3E@digeo.com>
	<Pine.GSO.4.30.0209172053360.3686-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@digeo.com, manfred@colorfullife.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <Pine.GSO.4.30.0209172053360.3686-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: jamal <hadi@cyberus.ca>
   Date: Tue, 17 Sep 2002 20:57:58 -0400 (EDT)
   
   I am not so sure with that 6% difference there is no other bug lurking
   there; 6% seems too large for an extra two PCI transactions per packet.

{in,out}{b,w,l}() operations have a fixed timing, therefore his
results doesn't sound that far off.

It is also one of the reasons I suspect Andrew saw such bad results
with 3c59x, but probably that is not the only reason.
