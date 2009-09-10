From: Andi Kleen <andi@firstfloor.org>
Subject: Re: TCP kernel tables overflowing after sustained 1000 new connections per second
Date: Thu, 10 Sep 2009 11:24:04 +0200
Message-ID: <87k5075f0r.fsf@basil.nowhere.org>
References: <c67e3dc60909091146j4aeaf422v4e0543eff87c7f9a@mail.gmail.com>
	<20090909.170824.141343404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulsheer@gmail.com, linux-kernel@vger.kernel.org,
	roque@di.fc.ul.pt, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755310AbZIJJYH@vger.kernel.org>
In-Reply-To: <20090909.170824.141343404.davem@davemloft.net> (David Miller's message of "Wed, 09 Sep 2009 17:08:24 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On a gigabit local LAN I can set the timeouts very low to encourage
> port reuse. A well known configuration issue with all OS's - just search
> for MyOS+TIMED_WAIT on google. No problems here.

The timeouts are what they are for a reason to detect old packets in
the network and prevent data corruption. That's why the RFCs require
them. 

Unless you never run on WANs or have very strong data integry checking
in your application (e.g. SSL) it's normally not a good idea to mess
with them.

When you run out of port space you should use more local IP addresses.

Possibly if you don't have problems with firewalls you could
also increase the port space, but that's still limited.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
