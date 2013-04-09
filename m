From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 18:24:59 -0700
Message-ID: <51636DEB.5000308@schaufler-ca.com>
References: <3505145.vfXt1x4t0P@sifl>   <20130408.171512.973275376690340387.davem@davemloft.net>   <2921619.mqaHl5PnPI@sifl>   <20130408.173325.1683493727549657170.davem@davemloft.net>   <51635573.7030706@schaufler-ca.com>  <1365467636.3887.67.camel@edumazet-glaptop>  <5163680F.4030200@schaufler-ca.com> <1365469759.3887.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pmoore@redhat.com,
	netdev@vger.kernel.org, mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1365469759.3887.69.camel@edumazet-glaptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/8/2013 6:09 PM, Eric Dumazet wrote:
> On Mon, 2013-04-08 at 17:59 -0700, Casey Schaufler wrote:
>
>> I don't see that with adding 4 bytes. Again, I'm willing to be
>> educated if I'm wrong.
> Feel free to add 4 bytes without having the 'align to 8 bytes' problem
> on 64 bit arches. Show us your patch.

Recall that it's replacing an existing 4 byte value with an 8 byte value.
My compiler days were quite short and long ago, but it would seem that
an 8 byte value ought not have an 'align to 8 bytes' problem.

Again, I'm willing to be educated.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

