From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 09:55:37 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327.095537.26269606.davem@redhat.com>
References: <20030327.054357.17283294.davem@redhat.com>
	<Pine.LNX.4.44.0303270917290.29072-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shmulik.hen@intel.com, dane@aiinet.com,
   bonding-devel@lists.sourceforge.net, bonding-announce@lists.sourceforge.net,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@transmeta.com
In-Reply-To: <Pine.LNX.4.44.0303270917290.29072-100000@home.transmeta.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Linus Torvalds <torvalds@transmeta.com>
   Date: Thu, 27 Mar 2003 09:22:29 -0800 (PST)

   I do agree that we should obviously not run bottom halves with
   interrupts disabled
   
Ok, so can we add a:

	if (irqs_disabled())
		BUG();

check to do_softirq()?

I'll address the rest of your email in a bit.
