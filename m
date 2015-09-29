From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH next 0/5] netfilter: Pass net into ip_route_me_harder
Date: Tue, 29 Sep 2015 20:32:20 +0200
Message-ID: <20150929183220.GA9620@salvia>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <87pp1fpy1b.fsf@x220.int.ebiederm.org>
 <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
 <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 25, 2015 at 03:01:42PM -0500, Eric W. Biederman wrote:
> 
> This is the next installment of my work to pass struct net through the
> output path so the code does not need to guess how to figure out which
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
> 
> This round the focus is our getting struct net passed in, instead of
> guess in the netfilter functions that reroute packets
> (ip_route_me_harder, and ip6_route_me_harder).  There is a bit more work
> on the ipv4 side as the ipv6 code on several of these code paths already
> passes in the struct net.

Series applied, thanks.

