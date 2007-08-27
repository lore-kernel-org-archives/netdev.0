From: David Miller <davem@davemloft.net>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Mon, 27 Aug 2007 14:56:00 -0700 (PDT)
Message-ID: <20070827.145600.102570576.davem@davemloft.net>
References: <46D2F301.7050105@katalix.com>
	<20070827.140251.95055210.davem@davemloft.net>
	<46D34517.4010505@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ossthema@de.ibm.com,
	akepner@sgi.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: jchapman@katalix.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965465AbXH0V54@vger.kernel.org>
In-Reply-To: <46D34517.4010505@katalix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 27 Aug 2007 22:41:43 +0100

> I don't recall saying anything in previous posts about this. Are you 
> confusing my posts with Jan-Bernd's?

Yes, my bad.

> Jan-Bernd has been talking about using hrtimers to _reschedule_
> NAPI. My posts are suggesting an alternative mechanism that keeps
> NAPI active (with interrupts disabled) for a jiffy or two after it
> would otherwise have gone idle in order to avoid too many interrupts
> when the packet rate is such that NAPI thrashes between poll-on and
> poll-off.

So in this scheme what runs ->poll() to process incoming packets?
The hrtimer?
