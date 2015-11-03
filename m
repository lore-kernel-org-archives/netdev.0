From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Tue, 3 Nov 2015 14:07:11 -0800
Message-ID: <CA+55aFzXv9KcyHJ4SfiL3Jihz6ObyiDPnbCnfy7HwAbXUsXf_A@mail.gmail.com>
References: <20151025114934.GA11108@ls3530.box>
	<CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com>
	<20151103.163324.221668446986372734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Helge Deller <deller@gmx.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	Jej B <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151103.163324.221668446986372734.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 3, 2015 at 1:33 PM, David Miller <davem@davemloft.net> wrote:
>
>> David: the issue wrt XPS is this:
>>
>>    #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map))   \
>>        / sizeof(u16))
>>
>> Comments?
>
> The PARISC folks did discuss this with us networking folks...
>
>         http://marc.info/?t=144554413000001&r=1&w=2

Ok. So that still leaves the "is it sane to lie about your
L1_CACHE_BYTES" question...

               Linus
