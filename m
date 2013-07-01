From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next 2/5] net: introduce generic inet_pton()
Date: Mon, 01 Jul 2013 15:05:15 +0800
Message-ID: <1372662315.2974.20.camel@cr0>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-3-git-send-email-amwang@redhat.com>
	 <20130627145116.03e2f892@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627145116.03e2f892@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 14:51 -0700, Stephen Hemminger wrote:
> >  
> > +static inline int inet_pton(const char *str, union inet_addr *addr)
> > +{
> >
> 
> A couple of comments:
> 1. No reason for this to be inline

Okay, I will move them into net/core/utils.c.

> 2. If function has same name as userspace it must have same arguments
>    and return value. Either:
>     a. rename it to kinet_pton or some other name
>     b. make it work the same.
> 

Makes sense too me, I will try your option b) first, if it is over-kill
I will fall back to option a).

Thanks!
