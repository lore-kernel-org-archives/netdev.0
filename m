From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 1/1] net: skbuff: fix compile error in skb_panic()
Date: Wed, 13 Feb 2013 11:52:21 -0500 (EST)
Message-ID: <20130213.115221.343418412847173849.davem@davemloft.net>
References: <1360754427-9051-1-git-send-email-james.hogan@imgtec.com>
	<CA+icZUVB9QaZfnKGSz_Dr=EADBtYULOHqEHDDocdXO5-Dy=uYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: james.hogan@imgtec.com, sakiwit@gmail.com,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	jiri@resnulli.us, netdev@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CA+icZUVB9QaZfnKGSz_Dr=EADBtYULOHqEHDDocdXO5-Dy=uYA@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Wed, 13 Feb 2013 13:41:21 +0100

> On Wed, Feb 13, 2013 at 12:20 PM, James Hogan <james.hogan@imgtec.com> wrote:
>> I get the following build error on next-20130213 due to the following
>> commit:
>>
>> commit f05de73bf82fbbc00265c06d12efb7273f7dc54a ("skbuff: create
>> skb_panic() function and its wrappers").
>>
>> It adds an argument called panic to a function that uses the BUG() macro
>> which tries to call panic, but the argument masks the panic() function
>> declaration, resulting in the following error (gcc 4.2.4):
>>
>> net/core/skbuff.c In function 'skb_panic':
>> net/core/skbuff.c +126 : error: called object 'panic' is not a function
>>
> 
> [ CC linux-netdev ]
> 
> Hmm, with gcc-4.6.3 on Ubuntu/precise I don't see this... compiler-specific?

Kconfig option specific.

Applied, thanks James.
