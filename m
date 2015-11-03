From: John David Anglin <dave.anglin@bell.net>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Tue, 3 Nov 2015 18:40:53 -0500
Message-ID: <0F1C5469-5397-4F1A-AF17-CC7D3112A436@bell.net>
References: <20151025114934.GA11108@ls3530.box> <CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com> <56393D46.6060903@gmx.de> <CA+55aFyENfhCBj4aaPRc2=82e=fjdg4wynCUCJc9Mbz1PwfCqA@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Helge Deller <deller@gmx.de>, David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <CA+55aFyENfhCBj4aaPRc2=82e=fjdg4wynCUCJc9Mbz1PwfCqA@mail.gmail.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-11-03, at 6:25 PM, Linus Torvalds wrote:

> But if it's actually possible that the pa-risc L1 line size is really
> just 16 bytes, I guess that objection to the patch goes away. My
> automatic reaction was "that's not real, it's some odd workaround",
> but if it is actually real...

See page 10 in this document:
https://parisc.wiki.kernel.org/images-parisc/e/e9/PA-8700wp.pdf

It shows the PA-8700 L1 design.  James' comments and this paper are the
basis for this change.

Dave
--
John David Anglin	dave.anglin@bell.net



