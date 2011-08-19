From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] bridge: add netfilter hook for forwarding 802.1D group
 addresses
Date: Fri, 19 Aug 2011 15:24:15 -0700
Message-ID: <20110819152415.00e1c795@nehalam.ftrdhcpuser.net>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
	<CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
	<20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
	<CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>
	<20110815150501.3a6cc432@nehalam.ftrdhcpuser.net>
	<CAEJpZP0fOydMMbgquAud7dfwcO28BXAMzAwnMjSZO6TvEjxgpQ@mail.gmail.com>
	<20110818081019.4b9bb79e@nehalam.ftrdhcpuser.net>
	<CAEJpZP2FGhPmTi0+eS+QRhj4y+aqfQHnEUrjmOOLHUay1SuAKg@mail.gmail.com>
	<20110818093941.5ebf716b@nehalam.ftrdhcpuser.net>
	<20110819022731.GC180151@jupiter.n2.diac24.net>
	<20110819135810.1a529ab2@nehalam.ftrdhcpuser.net>
	<184D23435BECB444AB6B9D4630C8EC830258A300@XMB-RCD-303.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Lamparter" <equinox@diac24.net>,
	"Nick Carter" <ncarter100@gmail.com>,
	"Ed Swierk" <eswierk@bigswitch.com>, <netdev@vger.kernel.org>,
	<bridge@linux-foundation.org>, <netfilter-devel@vger.kernel.org>
To: "Christian Benvenuti (benve)" <benve@cisco.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <184D23435BECB444AB6B9D4630C8EC830258A300@XMB-RCD-303.cisco.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Aug 2011 17:18:04 -0500
"Christian Benvenuti (benve)" <benve@cisco.com> wrote:

> The patch description and the code are clearly saying that STP is
> an exception, but I am just worried about the users.
> Maybe a proper description in the iptables help is sufficient.
> 
> Users may otherwise try to use this new hook for STP too
> (for example to generate logs or produce statistics/counters
> or divert STP traffic to userspace, etc).

STP traffic already goes to userspace. And gets processed
by the LOCAL_IN chain. So I don't think it is needed.


> Out of curiosity, ... if this gets accepted, shouldn't you provide
> NF_BR_LINK_LOCAL_OUT too?
> Or maybe you should call it NF_BR_LINK_LOCAL_FWD instead of
> NF_BR_LINK_LOCAL_IN?

Thanks, that is a better name, I'll change it in next version.
