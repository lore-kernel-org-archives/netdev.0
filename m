From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch 2/3] bridge: make bridge support netpoll
Date: Tue, 23 Mar 2010 13:06:12 +0800
Message-ID: <4BA84C44.4030707@redhat.com>
References: <4BA82186.3010204@redhat.com>	<1269318470.3552.54.camel@calx>	<4BA84607.7030304@redhat.com> <20100322.215703.77339158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322.215703.77339158.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue, 23 Mar 2010 12:39:35 +0800
> 
>> How could you let the bridge know netpoll is not sent to
>> the one that doesn't support netpoll during setup? This will
>> be complex, I am afraid.
> 
> Why does this matter at all?

Because currently we check netpoll support by ->ndo_poll_controller,
for example, tap driver doesn't have ->ndo_poll_controller now,
if I choose the target "@192.168.0.2/br0" where "192.168.0.2" is owned
by "tap0" which is managed by "br0", netconsole may not work.


> 
> I told you in another mail that we should do away with
> these callbacks and all the crazy 'npinfo' assignments
> and just do it in the generic code.

I think ->ndo_poll_controller is not in the case that you talked about.

Thanks.
