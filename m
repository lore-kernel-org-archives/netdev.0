From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3 9/9] selinux: use generic union inet_addr
Date: Mon, 19 Aug 2013 12:50:26 -0700 (PDT)
Message-ID: <20130819.125026.636442915180863272.davem@davemloft.net>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
	<1376907278-26377-10-git-send-email-amwang@redhat.com>
	<52127336.3080209@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	james.l.morris@oracle.com, sds@tycho.nsa.gov,
	eparis@parisplace.org, pmoore@redhat.com,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: casey@schaufler-ca.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <52127336.3080209@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It's so that you can pass a generic ipv4/ipv6 address blob into
things like printf formatting, and since there is an address family
member present, it knows what's in there and therefore one printf
format specifier can handle both ipv4 and ipv6 addresses.

Like you, I think these changes a complete waste of time too, I'm just
relaying what I was told.
