From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 23:40:22 +0100
Message-ID: <16822.12630.275389.575326@robur.slu.se>
References: <20041206205305.GA11970@soohrt.org>
	<20041207211035.GA20286@quickstop.soohrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261950AbULGWki@vger.kernel.org>
To: Karsten Desler <kdesler@soohrt.org>
In-Reply-To: <20041207211035.GA20286@quickstop.soohrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Karsten Desler writes:

 > I totally forgot to mention: There are approximately 100k concurrent
 > flows.

 > >From dmesg:
 > IP: routing cache hash table of 16384 buckets, 128Kbytes

 You can take a looks at stats w. rtstat. Hash spinning and how many new 
 entires create and how many warm you hit. 


 > Maybe there is some contention on the rt_hash_table spinlocks?
 > Is the attached patch enough to increase the size?

 There is boot option for this now

   rhash_entries=  [KNL,NET]
                        Set number of hash buckets for route cache


						   --ro
