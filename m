From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 0/8] textsearch: case insensitive pattern matching for netfilter
Date: Mon, 23 Jun 2008 18:25:54 -0700
Message-ID: <b25c3fa70806231825q21144461jdcc20cc77aff8c80@mail.gmail.com>
References: <b25c3fa70806210054o74a46068ifa3b396662080265@mail.gmail.com>
	 <20080623232756.GH20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>,
	"David Miller" <davem@davemloft.net>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080623232756.GH20815@postel.suug.ch>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2008/6/23 Thomas Graf <tgraf@suug.ch>:
> * Joonwoo Park <joonwpark81@gmail.com> 2008-06-21 00:54
>> This patchset aim at supporting case insensitive text search for netfilter
>> string extension.
>> It contains fixing of Boyer-Moore algorithm and Knuth-Morris-Pratt algorithm.
>> Also this includes bug fixing of Boyer-Moore algorithm.
>
> All patches look good, except that a general flags field in ts_config
> would make features like this easier to add going forward.
>
> It should be noted that this may slow down the algorithms noticeable for
> very large strings such as skb data buffers.
>

Thanks Thomas for reviewing this.

Do you mean a note by commenting on the code? or any message to user?
