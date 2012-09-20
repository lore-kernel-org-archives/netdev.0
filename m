From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 2/4] ipv6: unify conntrack reassembly expire code with
 standard one
Date: Thu, 20 Sep 2012 15:41:37 +0800
Message-ID: <1348126897.17345.11.camel@cr0>
References: <1348023011-16195-1-git-send-email-amwang@redhat.com>
	 <1348023011-16195-3-git-send-email-amwang@redhat.com>
	 <Pine.LNX.4.64.1209191659150.12601@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1209191659150.12601@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-19 at 17:12 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 19 Sep 2012, Cong Wang wrote:
> 
> [cut]
> > With this patch applied, I can see ICMP Time Exceeded sent
> > from the receiver when the sender sent out 3/4 fragmented
> > IPv6 UPD packet.
> 
> Typo "UPD" -> "UDP"
> 
> If people want to redo the IPv6 UDP fragment tests, they can use my scapy 
> script, and comment out sending the last fragment:
>   https://github.com/netoptimizer/network-testing/blob/master/scapy/ipv6_fragment01.py
> 
> Another thing, could you please "mark"/put the version of the patch in the 
> subject line, like:
> 
>   [PATCH V4 2/4] ipv6: ...
> 
> This makes it easier, to follow on which version of the patch people are 
> replying to.
> 
> With git send-email I think you have to do:
> 
>    git send-email --subject-prefix="PATCH V4"
> 
> And with stg (stacked git) I usually do:
> 
>    stg mail --version "V4" --to netdev ...

Thanks, Jesper!

Unfortunately, git-send-email on F16 doesn't have --subject-prefix
option (git-format-patch does), that is why I didn't add "V4" to every
patch. Perhaps I should use git-format-patch + git-send-email next time.


