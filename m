From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] netfilter: save the hash of the tuple in the original
 direction for latter use
Date: Fri, 20 Aug 2010 07:10:40 +0800
Message-ID: <AANLkTinA3-KMPKJa-66QCMUpbDFwey2mjE=VN=9=zg=6@mail.gmail.com>
References: <1282228389-3029-1-git-send-email-xiaosuo@gmail.com>
 <20100819152149.GA19744@Krystal> <AANLkTim5wn0Y-+081gvm7FkWx3NioRvtRMWy2uF4nji2@mail.gmail.com>
 <1282232786.2549.60.camel@edumazet-laptop> <20100819161112.GA24357@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100819161112.GA24357@Krystal>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 20, 2010 at 12:11 AM, Mathieu Desnoyers
<mathieu.desnoyers@polymtl.ca> wrote:
>
> Ah, I see. But I think the static variable should stay declared outside
> of the function scope, with a nice comment explaining why it's not
> initialized at init-time.
>
> Hiding global state in function code is usually frowned upon.
>

I don't agree with you. We'd better not expose the variable which
isn't expected to be used by others. If not, maybe someone will misuse
it. The user should only reply on the interface, but not the internal
implementation.

Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
