From: Hideo AOKI <haoki@redhat.com>
Subject: Re: possible recursive locking in udp4_lib_rcv
Date: Fri, 08 Aug 2008 23:50:17 -0400
Message-ID: <489D13F9.4000805@redhat.com>
References: <20080807234613.GA9598@google.com> <E1KRSxN-0005Ng-00@gondolin.me.apana.org.au> <20080808143741.GA20777@gondor.apana.org.au> <20080808150108.GA21048@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761283AbYHIDup@vger.kernel.org>
In-Reply-To: <20080808150108.GA21048@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Herbert,

Herbert Xu wrote:
> On Fri, Aug 08, 2008 at 10:37:41PM +0800, Herbert Xu wrote:
>> Never mind, I see the reason why it's there.  What we should do
>> is drop the lock when we hit an encapsulated socket since they
>> don't need it at all.
> 
> Here is the patch:
> 
> udp: Drop socket lock for encapsulated packets

Thank very much for fixing the bug.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
