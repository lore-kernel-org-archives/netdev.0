From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 1/1] vxlan: insert ipv6 macro
Date: Wed, 12 Oct 2016 15:16:38 +0200
Message-ID: <20161012151638.6250dff6@griffin>
References: <1476174211-9358-1-git-send-email-zyjzyj2000@gmail.com>
        <20161011160615.7f7f7746@griffin>
        <CAD=hENc0pQPKDvq_HJ14BhNzAWQndZ4GMo_-_D4EtQMgs9tv2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, pabeni@redhat.com,
        daniel@iogearbox.net, Pravin B Shelar <pshelar@nicira.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        hannes@stressinduktion.org, "David S. Miller" <davem@davemloft.net>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47920 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932607AbcJLNRa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Oct 2016 09:17:30 -0400
In-Reply-To: <CAD=hENc0pQPKDvq_HJ14BhNzAWQndZ4GMo_-_D4EtQMgs9tv2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Oct 2016 21:01:54 +0800, zhuyj wrote:
> How to explain the following source code? As you mentioned,  are the
> #ifdefs in the following source pointless?

They are not, the code would not compile without them. Look how struct
vxlan_dev is defined.

Those are really basic questions you have. I suggest you try yourself
before asking such questions next time. In this case, you could
trivially remove the #ifdef and see for yourself, as I explained in the
previous email. Please do not try to offload your homework to other
people. It's very obvious you didn't even try to understand this, even
after the feedback you received.

And do not top post.

Thanks,

 Jiri
