From: Andi Kleen <andi@firstfloor.org>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 22:59:01 +0100
Message-ID: <20090318215901.GV11935@one.firstfloor.org>
References: <49C12E64.1000301@us.ibm.com> <87prge1rhu.fsf@basil.nowhere.org> <49C16294.8050101@us.ibm.com> <1237412732.29116.2.camel@lb-tlvb-eliezer> <49C16CD4.3010708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Andi Kleen <andi@firstfloor.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: Vernon Mauery <vernux@us.ibm.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49C16CD4.3010708@us.ibm.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Thanks.  I will test to see how this affects this lock contention the
> next time the broadcom hardware is available.

The other strategy to reduce lock contention here is to use TSO/GSO/USO.
With that the lock has to be taken less often because there are less packets
travelling down the stack. I'm not sure how well that works with netperf style 
workloads though. Using multiple TX queues is probably better though if you have
capable hardware. Or ideally both.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
