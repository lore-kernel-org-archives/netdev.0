From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [Patch net-next v3 9/9] selinux: use generic union inet_addr
Date: Mon, 19 Aug 2013 14:42:55 -0700
Message-ID: <5212915F.20905@schaufler-ca.com>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com> <1376907278-26377-10-git-send-email-amwang@redhat.com> <52127336.3080209@schaufler-ca.com> <20130819.125026.636442915180863272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	james.l.morris@oracle.com, sds@tycho.nsa.gov,
	eparis@parisplace.org, pmoore@redhat.com,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130819.125026.636442915180863272.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/19/2013 12:50 PM, David Miller wrote:
> It's so that you can pass a generic ipv4/ipv6 address blob into
> things like printf formatting, and since there is an address family
> member present, it knows what's in there and therefore one printf
> format specifier can handle both ipv4 and ipv6 addresses.

The patch message needs to say that, then.

> Like you, I think these changes a complete waste of time too, I'm just
> relaying what I was told.

Well, they certainly don't appear to add any value on their own.
I also generally oppose doing clever things with data structures.
I recently got bitten by the "obvious" relationships between
sockaddr, sockaddr_in and sockaddr_in6, and I've been doing this
stuff since before ioctl was invented.

