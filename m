From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] bonding: clean up netpoll code
Date: Wed, 01 Dec 2010 19:15:43 +0800
Message-ID: <4CF62E5F.2090507@redhat.com>
References: <20101201075043.5741.29172.sendpatchset@localhost.localdomain> <1291190612.2856.481.camel@edumazet-laptop> <4CF606C7.6020606@redhat.com> <20101201090621.GA11366@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101201090621.GA11366@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/10 17:06, Herbert Xu wrote:
> On Wed, Dec 01, 2010 at 04:26:47PM +0800, Cong Wang wrote:
>>
>> Is this necessary?
>> It is just replacing checking IFF_IN_NETPOLL with netpoll_tx_running(),
>> you might need to take a look at the bridge code.
>
> I agree with Eric.  The patch does look pretty scary right now.
>
> Each patch should do one thing and one thing only.
>

Ok, I will separate that part out.

Thanks!
