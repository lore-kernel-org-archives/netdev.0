From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: nftables: Do not run chains in the wrong
 network namespace
Date: Fri, 19 Jun 2015 19:21:28 +0200
Message-ID: <20150619172128.GA4607@salvia>
References: <87oakbg0ym.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87oakbg0ym.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 19, 2015 at 10:41:21AM -0500, Eric W. Biederman wrote:
> 
> Currenlty nf_tables chains added in one network namespace are being
> run in all network namespace.  The issues are myriad with the simplest
> being an unprivileged user can cause any network packets to be dropped.
> 
> Address this by simply not running nf_tables chains in the wrong
> network namespace.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

@David: Patrick sent a similar patch to address this, if you can get
this into the net tree, I'll make sure this propagates to -stable.
Thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
