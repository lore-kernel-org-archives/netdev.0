From: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Wed, 26 Aug 2015 13:01:12 +0000
Message-ID: <D2037365.41362%Shaun.Crampton@metaswitch.com>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com>
 <20150826074959.48aea34c@as>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Peter White <Peter.White@metaswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chuck Ebbert <cebbert.lkml@gmail.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150826074959.48aea34c@as>
Content-Language: en-US
Content-ID: <D1D3159EF73D324F97D25C9E09CB1FDF@metaswitch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>And the kernel thinks it's
>outside of any normal text section, so it does not try to dump any
>code from before the instruction pointer.
>
>   0:	48 8b 88 40 03 00 00 	mov    0x340(%rax),%rcx
>   7:	e8 1d dd dd ff       	callq  0xffffffffffdddd29
>   c:	5d                   	pop    %rbp
>   d:	c3                   	retq
>
>Did you write your own module loader or something?

We certainly didn't but CoreOS may have.  I've asked CoreOS if they know
what's going on.

Are there any extra diagnostics I can gather from a CoreOS system to help
figure out what's going on there?  Is there anything I can do to get more
useful diagnostics when one of these failures occur?  As noted, I can
reproduce the issue but it's expensive, requiring hundreds of VMs to
hammer away for an hour or so.
