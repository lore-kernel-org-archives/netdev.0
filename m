From: Cong Wang <amwang@redhat.com>
Subject: Re: [v3 PATCH 2/2] netpoll: remove IFF_IN_NETPOLL flag
Date: Wed, 08 Dec 2010 16:52:54 +0800
Message-ID: <4CFF4766.9010909@redhat.com>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain> <20101208075218.5792.64791.sendpatchset@localhost.localdomain> <AANLkTindQMNKhC2aowUyjm=uO8gFKqOOPa9HXSU1q7Gh@mail.gmail.com> <4CFF437D.1060904@redhat.com> <AANLkTikdweTkcsxTgf+phRaHYWMb9eAwrtr1xJr+0C1s@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikdweTkcsxTgf+phRaHYWMb9eAwrtr1xJr+0C1s@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/08/10 16:49, Changli Gao wrote:
> On Wed, Dec 8, 2010 at 4:36 PM, Cong Wang<amwang@redhat.com>  wrote:
>>
>> A few lines above that code said:
>>
>> /* Private (from user) interface flags (netdevice->priv_flags). */
>>
>> unless this comment is wrong, we don't need to worry.
>>
>
> It seems these macros are exported to user space wrongly.
>

Maybe we should add #ifdef __KERNEL__ to protect them, I think.
