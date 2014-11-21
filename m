From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Fri, 21 Nov 2014 11:40:49 -0800
Message-ID: <CA+55aFy4d1uii5078NxT7E9cTCbHfpgMitA4goHJadRGM8pshg@mail.gmail.com>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
	<20141119.161744.1661940121298888832.davem@davemloft.net>
	<20141119213006.GE7996@ZenIV.linux.org.uk>
	<20141119.165340.2162829993279387495.davem@davemloft.net>
	<20141120214753.GR7996@ZenIV.linux.org.uk>
	<1416520542.8629.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141120222506.GS7996@ZenIV.linux.org.uk>
	<1416524035.8629.54.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141121084956.GT7996@ZenIV.linux.org.uk>
	<063D6719AE5E284EB5DD2968C1650D6D1C9F6930@AcuExch.aculab.com>
	<20141121193911.GU7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141121193911.GU7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2014 at 11:39 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> I'm not at all sure that _anything_ has valid reasons for draining iovecs.
> Maintaining a struct iov_iter and modifying it is easy and actually faster...

For new code, I agree. But the whole "draining iovec's" is a fairly
common old model.

                  Linus
