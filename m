From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] Networking
Date: Fri, 22 Aug 2014 14:40:11 -0700 (PDT)
Message-ID: <20140822.144011.1708163582352708529.davem@davemloft.net>
References: <20140822.114711.856705392345846995.davem@davemloft.net>
	<CA+55aFxsf02Lt+rFOxf0rXu1WoqZW0omGzwdHUfSfo+O9EqUAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxsf02Lt+rFOxf0rXu1WoqZW0omGzwdHUfSfo+O9EqUAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 22 Aug 2014 14:32:58 -0700

> On Fri, Aug 22, 2014 at 11:47 AM, David Miller <davem@davemloft.net> wrote:
>>
>> Here are some bug fixes that have piled up during ksummit/linuxcon.
> 
> Hmm. What happened to the patch titled "mac80211: fix channel switch
> for chanctx-based drivers" by Michal Kazior?
> 
> That one fixes a rather nasty oops that results in dead machines. It's
> generic wireless code, but hits with at least intel wireless cards. It
> needs the AP to send a channel switch request, but if that happens
> (and it does), the kernel goes belly-up.

Yeah, I haven't gotten a pull request from John Linville yet, he's
probably still busy conferencing or travelling back hom.

I think you can apply it directly and none of us will mind, and GIT
will sort it all out during the next merge.
