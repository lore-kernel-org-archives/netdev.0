From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: Re: Billing 1: WAS (Re: [PATCH 2/4] deferred drop, __parent	workaround,
 reshape_fail , netdev@oss.sgi.com ,
Date: Mon, 23 Aug 2004 11:33:19 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <4129B9DF.8030402@crocetta.org>
References: <411C0FCE.9060906@crocetta.org>	 <1092401484.1043.30.camel@jzny.localdomain>	 <20040816072032.GH15418@sunbeam2>	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org> <1093187835.1042.95.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>,  devik@cdi.cz,
 netdev@oss.sgi.com,  netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: hadi@cyberus.ca
In-Reply-To: <1093187835.1042.95.camel@jzny.localdomain>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

jamal wrote:

>Apologies for latency - was busy at (my real) work.
>  
>
you don't have to apologize for that :) it's something
everybody can easily understand :)

>Let me break this email into several ones since it is getting long.
>
>On Tue, 2004-08-17 at 09:40, sandr8 wrote:
>  
>
>>something like enqueue(dev) that will indirectly call dev->qdisc->enqueue
>>and handle in that single place that stuff that does not fit well in 
>>net/core/dev.c
>>    
>>
>
>Enqueue of _root_ qdisc is the place to do it.
>Maybe even dev.c calls to it. Lets defer this to the next email.
>  
>
then i should add some code in every qdisc that can
be root and execute it only if it is actually root?

isn't it more complex?

>Let me say this:
>I am happy with Haralds billing patch which is already in as is.
>In other words, although there is an accounting discrepancy it is not
>that big.
>What does that mean? unbilling is not something to rush in and patch in
>if its going to have an impact on other pieces. It doesnt matter whether
>it goes in in 2.6.20 or doesnt even go in as far as i am concerned. 
>However this shouldnt dicourage you because you have actually opened an
>issue we need to resolve. So please keep up the discussions.
>  
>
sure, for the time being i thought to simply concentrate
on the rest and maintain it as indipendent as possible
from the choice that will be taken.

cheers
alessandro
