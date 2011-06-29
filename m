From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V7 2/4 net-next] skbuff: Add userspace zero-copy
 buffers in skb
Date: Tue, 28 Jun 2011 21:28:54 -0700
Message-ID: <1309321734.3559.20.camel@localhost.localdomain>
References: <1309189510.21764.1.camel@localhost.localdomain>
	 <20110627.155426.51839633424542723.davem@davemloft.net>
	 <1309279892.3559.6.camel@localhost.localdomain>
	 <20110628.163508.222352070705159851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, avi@redhat.com,
	arnd@arndb.de, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110628.163508.222352070705159851.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have submitted this patchset from Version 1 to Version 7 already in
the past few months.
Here is the link to the patchset:

http://lists.openwall.net/netdev/2011/05/28/

I am working on V8 now.

Thanks
Shirley


On Tue, 2011-06-28 at 16:35 -0700, David Miller wrote:
> From: Shirley Ma <mashirle@us.ibm.com>
> Date: Tue, 28 Jun 2011 09:51:32 -0700
> 
> > On Mon, 2011-06-27 at 15:54 -0700, David Miller wrote:
> >> From: Shirley Ma <mashirle@us.ibm.com>
> >> Date: Mon, 27 Jun 2011 08:45:10 -0700
> >> 
> >> > To support skb zero-copy, a pointer is needed to add to skb share
> >> info.
> >> > Do you agree with this approach? If not, do you have any other
> >> > suggestions?
> >> 
> >> I really can't form an opinion unless I am shown the complete
> >> implementation, what this give us in return, what the impact is,
> etc. 
>  ..
> > You can see the overall CPU saved 50% w/i zero-copy.
> > 
> > The impact is every skb allocation consumed one more pointer in skb
> > share info, and a pointer check in skb release when last reference
> is
> > gone.
> > 
> > For skb clone, skb expand private head and skb copy, it still keeps
> copy
> > the buffers to kernel, so we can avoid user application, like
> tcpdump to
> > hold the user-space buffers too long.
> 
> Ok, now show me the "complete implementation".  I'm as interested in
> the code as I am in the numbers, that's why I asked for both. 

