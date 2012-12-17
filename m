From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Mon, 17 Dec 2012 07:58:38 -0500
Message-ID: <50CF16FE.5040300@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com> <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr> <50CE0921.7060306@mojatatu.com> <alpine.LNX.2.01.1212161850530.27614@nerf07.vanv.qr> <50CE307E.40304@mojatatu.com> <alpine.LNX.2.01.1212162220270.20281@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1212162220270.20281@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-12-16 04:21 PM, Jan Engelhardt wrote:

> If you have a preexisting clone of any linux tree, you can utilize
> `git remote add ...` to only grab the deltas.

It downloaded eventually.
So looking at this quickly, basic question: is xtables2 different API 
wise from what we do today in act_ipt?
Second: Are chain names unique system wide? i.e at the moment we send
a hook and table selection?
The patch i have currently for the kernel tries to pursue an approach 
that maximizes code reuse - depending on your answer I may go the 
approach of having a separate act_xt and hope you can build on top of that.

cheers,
jamal

