From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3 9/9] selinux: use generic union inet_addr
Date: Mon, 19 Aug 2013 23:48:40 -0700 (PDT)
Message-ID: <20130819.234840.1640929202046409588.davem@davemloft.net>
References: <52127336.3080209@schaufler-ca.com>
	<20130819.125026.636442915180863272.davem@davemloft.net>
	<5212915F.20905@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	james.l.morris@oracle.com, sds@tycho.nsa.gov,
	eparis@parisplace.org, pmoore@redhat.com,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: casey@schaufler-ca.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <5212915F.20905@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Casey Schaufler <casey@schaufler-ca.com>
Date: Mon, 19 Aug 2013 14:42:55 -0700

> On 8/19/2013 12:50 PM, David Miller wrote:
>> It's so that you can pass a generic ipv4/ipv6 address blob into
>> things like printf formatting, and since there is an address family
>> member present, it knows what's in there and therefore one printf
>> format specifier can handle both ipv4 and ipv6 addresses.
> 
> The patch message needs to say that, then.

Actually, that belongs in the "0/N" posting, the contents of which
will end up in the merge commit should I apply the series.
