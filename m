From: Cong Wang <amwang@redhat.com>
Subject: Re: [v3 PATCH 2/2] netpoll: remove IFF_IN_NETPOLL flag
Date: Wed, 08 Dec 2010 16:36:13 +0800
Message-ID: <4CFF437D.1060904@redhat.com>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain> <20101208075218.5792.64791.sendpatchset@localhost.localdomain> <AANLkTindQMNKhC2aowUyjm=uO8gFKqOOPa9HXSU1q7Gh@mail.gmail.com>
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
In-Reply-To: <AANLkTindQMNKhC2aowUyjm=uO8gFKqOOPa9HXSU1q7Gh@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/08/10 16:16, Changli Gao wrote:
>
> You can't change the values of these macros or delete some of them,
> because they are exported to user space and are parts of ABI.
>

A few lines above that code said:

/* Private (from user) interface flags (netdevice->priv_flags). */

unless this comment is wrong, we don't need to worry.
