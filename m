From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 28/29] net/: rename net_random() to prandom_u32()
Date: Tue, 25 Dec 2012 20:47:26 +0900
Message-ID: <CAC5umyhhTJWfsFtZ_5Qm_HJHy2+sx7iMgcV=T=MMKLdi50-HQw@mail.gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
	<1356315256-6572-29-git-send-email-akinobu.mita@gmail.com>
	<20121225002149.GA5235@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Jesse Gross <jesse@nicira.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, dev@openvswitch.org,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121225002149.GA5235@neilslaptop.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/12/25 Neil Horman <nhorman@tuxdriver.com>:
> On Mon, Dec 24, 2012 at 11:14:15AM +0900, Akinobu Mita wrote:
>> Use more preferable function name which implies using a pseudo-random
>> number generator.
>>
>> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
>> Cc: Jesse Gross <jesse@nicira.com>
>> Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>> Cc: Sridhar Samudrala <sri@us.ibm.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Steffen Klassert <steffen.klassert@secunet.com>
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: linux-sctp@vger.kernel.org
>> Cc: dev@openvswitch.org
>> Cc: netdev@vger.kernel.org
>> ---
>>  include/net/red.h         | 2 +-
>>  net/802/garp.c            | 2 +-
>>  net/openvswitch/actions.c | 2 +-
>>  net/rds/bind.c            | 2 +-
>>  net/sctp/socket.c         | 2 +-
>>  net/xfrm/xfrm_state.c     | 2 +-
>>  6 files changed, 6 insertions(+), 6 deletions(-)
>>
> I'm largely indifferent to this patch, but I kind of feel like its just churn.
> Whats the real advantage in making this change?  I grant that it clearly
> indicates the type of random number generator we're using at a given call site,
> But for those using net_random, you probably don't care too much about
> the source of your random bits.  If you did really want true random vs.
> pseudo-random data, you need to explicitly use the right call.  You're previous
> patch series did good cleanup on differentiating the different random calls, but
> this just seems like its removing what is otherwise useful indirection.

I overlooked the importance of  net_random() indirection.
Thanks for the feedback. I'll leave all net_random() callers as-is in
the next version.
