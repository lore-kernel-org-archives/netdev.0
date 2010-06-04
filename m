From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC nf-next-2.6] conntrack: per cpu nf_conntrack_untracked
Date: Fri, 04 Jun 2010 14:29:24 +0200
Message-ID: <4C08F1A4.2050906@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation> <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com> 	<4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop> 	<1271948029.7895.5707.camel@edumazet-laptop> <20100422155123.GA2524@linux.vnet.ibm.com> 	<1271952128.7895.5851.camel@edumazet-laptop> <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk> 	<1272056237.4599.7.camel@edumazet-laptop> <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk> 	<1272139861.20714.525.camel@edumazet-laptop> <1272292568.13192.43.camel@jdb-workstation> 	<1275340896.2478.26.camel@edumazet-laptop> <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com> 	<1275368732.2478.88.camel@edumazet-laptop> <4C04DE73.6050605@trash.net> 	<1275388310.2738.2.camel@edumazet-laptop> <4C04E3E2.702020
 9@trash.net> 	<1275409203.2738.227.camel@edumazet-laptop> <4C08E62A.9020607@trash.net> <AANLkTilKEpFTg5bH8d9UE3a3DVJNAGYz10Jgkt6lXtJ0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTilKEpFTg5bH8d9UE3a3DVJNAGYz10Jgkt6lXtJ0@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changli Gao wrote:
> On Fri, Jun 4, 2010 at 7:40 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Eric Dumazet wrote:
>>> Obviously, an IPS_UNTRACKED bit would be much easier to implement.
>>> Would it be acceptable ?
>> That also would be fine. However the main idea behind using a nfctinfo
>> bit was that we wouldn't need the untracked conntrack anymore at all.
>> But I guess a per-cpu untrack conntrack would already be an improvement
>> over the current situation.
> 
> I think Eric didn't mean ip_conntrack_info but ip_conntrack_status
> bit. Since we have had a IPS_TEMPLATE bit, I think another
> IPS_UNTRACKED bit is also acceptable.

Yes, of course. But using one of these bits implies that we'd still
have the untracked conntrack.
