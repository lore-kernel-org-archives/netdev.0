From: Moahn Reddy <mohanreddykv@gmail.com>
Subject: Re: [patch] ipvs: off by one in set_sctp_state()
Date: Mon, 22 Apr 2013 15:19:24 +0530
Message-ID: <517507A4.7070406@gmail.com>
References: <20130420112455.GA30198@elgon.mountain> <alpine.LFD.2.00.1304201504510.1593@ja.ssi.bg> <20130422041151.GM15680@verge.net.au> <alpine.LFD.2.00.1304220843560.1626@ja.ssi.bg> <51750016.5080600@gmail.com> <20130422093016.GB8936@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>,
	Wensong Zhang <wensong@linux-vs.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130422093016.GB8936@mwanda>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

I am not saying that that is not a problem. Yes, we need to fix that 
array issue. I just said that I thought 0 to 254 enough at that time.

Thanks,
Mohan

On Monday 22 April 2013 03:00 PM, Dan Carpenter wrote:
> On Mon, Apr 22, 2013 at 02:47:10PM +0530, Moahn Reddy wrote:
>> Hi,
>>
>> I see there is no problem in the code regarding the state change.
>> And the thing why I took 255 in the sctp_events array is that as per
>> the sctp specification, the 255 message is reserved, so I thought 0
>> to 254 messages are enough.
> The issue is can chunk_type in set_sctp_state() be 255?  How is
> this prevented in the code?
>
> regards,
> dan carpenter
>

