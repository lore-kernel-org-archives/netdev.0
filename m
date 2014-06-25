From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix setting csum_start in tcp_gso_segment
Date: Wed, 25 Jun 2014 11:52:58 -0700 (PDT)
Message-ID: <20140625.115258.1446490446271879078.davem@davemloft.net>
References: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
	<CA+55aFxyZP_jXT-bLyFjJMp4WfVZp5vFtpu+-6_qCi46xkceQg@mail.gmail.com>
	<20140625141052.GA1096@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, therbert@google.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davej@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140625141052.GA1096@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Wed, 25 Jun 2014 10:10:52 -0400

> On Tue, Jun 24, 2014 at 09:17:25PM -0700, Linus Torvalds wrote:
>  > On Tue, Jun 24, 2014 at 9:03 PM, Tom Herbert <therbert@google.com> wrote:
>  > >
>  > > It looks like a likely culprit is that SKB_GSO_CB()->csum_start is
>  > > not set correctly when doing non-scatter gather. We are using
>  > > offset as opposed to doffset.
>  > >
>  > > Reported-by: Dave Jones <davej@redhat.com>
>  > 
>  > DaveJ, I think you triggered this in five minutes on your box, and I
>  > don't recall seeing anybody else reporting the oops (and google
>  > doesn't find anything in the last month). So it's presumably somewhat
>  > hw-specific. Does this fix the problem?
> 
> It's survived routing ~1GB of packets overnight, so I'd call this good.

Tom, please adjust the Subject line as suggested by Eric Dumazet and add
a Tested-by: for Dave.

Thanks!
