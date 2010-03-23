From: David Miller <davem@davemloft.net>
Subject: Re: [RFC Patch 2/3] bridge: make bridge support netpoll
Date: Mon, 22 Mar 2010 21:59:36 -0700 (PDT)
Message-ID: <20100322.215936.113720990.davem@davemloft.net>
References: <1269318470.3552.54.camel@calx>
	<4BA84607.7030304@redhat.com>
	<1269319861.3552.87.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
To: mpm@selenic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269319861.3552.87.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Mon, 22 Mar 2010 23:51:01 -0500

> On Tue, 2010-03-23 at 12:39 +0800, Cong Wang wrote:
>> Matt Mackall wrote:
>> How could you let the bridge know netpoll is not sent to
>> the one that doesn't support netpoll during setup? This will
>> be complex, I am afraid.
> 
> I thought I saw a simple loop over bridge devices at poll time in your
> patch. So it should be a simple matter of skipping unsupported devices
> in that loop.

It's because of all that "assign ->npinfo to slaves" crap he has to do
the way his patches are currently implemented.

It's basically another sign that the design is wrong.
