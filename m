From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netfilter: nftables: Do not run chains in the
 wrong network namespace
Date: Tue, 23 Jun 2015 06:23:45 -0700 (PDT)
Message-ID: <20150623.062345.2201329993068259127.davem@davemloft.net>
References: <87oakbg0ym.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, kaber@trash.net
To: ebiederm@xmission.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87oakbg0ym.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 19 Jun 2015 10:41:21 -0500

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

Applied.
