From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix netfilter refcounting [was Re: Conntrack leak
 (2.6.2rc2)]
Date: Tue, 3 Feb 2004 10:27:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203102712.02626ed5.davem@redhat.com>
References: <Pine.LNX.4.33.0402031629150.11737-100000@blackhole.kfki.hu>
	<Pine.LNX.4.33.0402031825170.11950-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: steve@navaho.co.uk, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <Pine.LNX.4.33.0402031825170.11950-100000@blackhole.kfki.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Feb 2004 18:43:38 +0100 (CET)
Jozsef Kadlecsik <kadlec@blackhole.kfki.hu> wrote:

> Steve Hill reported a conntrack leakage in 2.6.2-rc2 when nat is enabled
> and the system forwards fragmented packets. It turned out that an
> nf_conntrack_put was missing from ip_copy_metadata:

Nevermind my previous email, it was a total thinko... you're patch
is obviously correct and we had this same damn exact problem with
the bridging skbuff nf objects as well. (see changeset 1.1474.41.3)

I'll apply your patch and push to Linus now.  Thanks.
