From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6] iptables CLUSTERIP target)
Date: Fri, 22 Oct 2004 00:53:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021225315.GH19714@rei.reeler.org>
References: <20041021142527.GG3551@sunbeam.de.gnumonks.org> <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@netfilter.org>, lmb@suse.de, ahu@ds9a.nl,
        hch@infradead.org, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au> 2004-10-22 07:31
> Initially I considered an interface where kernel users can register
> themselves using a string as the key.  But I soon realised that we
> could simply allow the netlink_family field to be an arbitrary integer
> that is used as a key to a hash table.

Sounds like a good idea, converting nl_table and nl_nonroot into
a hash table won't be much of a problem. The netlink device driver
must probably be changed to create devices on the fly if we want
modules to be able to register netlink families. The same goes
for some selinux stuff but this is minor.

The only real problem I see is sk_protocol being only 8bit as
limiting factor.
