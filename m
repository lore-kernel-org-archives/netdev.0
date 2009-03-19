From: Andi Kleen <andi@firstfloor.org>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 19 Mar 2009 14:46:49 +0100
Message-ID: <20090319134649.GX11935@one.firstfloor.org>
References: <49C12E64.1000301@us.ibm.com> <87prge1rhu.fsf@basil.nowhere.org> <1237467559.6926.31.camel@hermosa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Vernon Mauery <vernux@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: "Peter W. Morreale" <pmorreale@novell.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1237467559.6926.31.camel@hermosa>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Recall that adaptive spin,developed in RT, is now in mainline. 

For mutexes, but not for spinlocks. And qdisc uses spinlocks.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
