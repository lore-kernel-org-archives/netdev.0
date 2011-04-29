From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] bridge: Module use count must be updated as
	 bridges are created/destroyed
Date: Fri, 29 Apr 2011 09:31:27 +0100
Message-ID: <4DBA937F020000780003ED96@vpn.id2.novell.com>
References: <4DBA830A020000780003ED5D@vpn.id2.novell.com>
 <20110429.002530.112581952.davem@davemloft.net>
 <4DBA87B6020000780003ED74@vpn.id2.novell.com>
 <20110429.011051.183061494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@linux-foundation.org>,
	<bridge@lists.linux-foundation.org>, <jeffm@suse.com>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20110429.011051.183061494.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 29.04.11 at 10:10, David Miller <davem@davemloft.net> wrote:
> From: "Jan Beulich" <JBeulich@novell.com>
> Date: Fri, 29 Apr 2011 08:41:10 +0100
> 
>> You talk of rmmod on the very module, but the issue is about
>> modprobe -r on a dependent module. I cannot believe you consider
>> it correct that *implicit* unloading of bridge.ko should happen when
>> bridges are configured.
> 
> Which module in particular depends upon bridge and causes the
> problem?

The problem was observed (a long time ago) with ebtable_broute,
and I cannot see how this would have changed meanwhile.

Jan

