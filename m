From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] string matching based packet classification/filtering
Date: Thu, 17 Feb 2005 14:31:14 +0100
Message-ID: <20050217133114.GU31837@postel.suug.ch>
References: <20050215203211.GL31837@postel.suug.ch>
	<42126C9B.5060406@eurodev.net>
	<20050216223038.GQ31837@postel.suug.ch>
	<4213ECC9.30502@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <4213ECC9.30502@eurodev.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

> >The matching algorithm would parse the array as a finite automation
> >eating up byte by byte in the text.
> >
> 
> Looks good but Boyer-Moore algorithm doesn't need this at all. BM 
> doesn't support wildcards like '*' because of the shiftings that it uses 
> to look for matches. This issue together with memory consumption are two 
> limitations that we have to live with if we want to use BM. Anyway I 
> think it's worth it because we can perform search in O(n/m).

This would be _additional_ to BM/KMP/naive/finite automata/you name it.
The benefit of libqsearch is hide various algorithms behind a single
interface, isn't it? It's argueable whether it would make sense to try
and rule out bad shifts while parsing a chain of non-wildcard regular
expression tokens but I guess that would be over the top.
