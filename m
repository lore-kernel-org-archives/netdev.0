From: "David S. Miller" <davem@redhat.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 17:18:19 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020520.171819.71992193.davem@redhat.com>
References: <200205210011.EAA04286@sex.inr.ac.ru>
	<3CE99434.20E7479C@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, ak@suse.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com
In-Reply-To: <3CE99434.20E7479C@mvista.com>
List-Id: netdev.vger.kernel.org

   From: george anzinger <george@mvista.com>
   Date: Mon, 20 May 2002 17:26:29 -0700

   Ah, but we have.  in_interrupt() was fixed about a month
   ago.  I think Robert got it into all the patches.  Whats
   more, it is a bit faster too :)

Well, back to the main point, this code is pretty stable by
any measurement.

I truly believe it is some side effect of either a preemption
gotcha or a driver bug.
