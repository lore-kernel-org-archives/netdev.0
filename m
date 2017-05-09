From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v7 5/5] virtio_net: check return value of skb_to_sgvec always
Date: Tue, 9 May 2017 16:10:27 +0200
Message-ID: <CAHmME9oPYuT2q8_geacn=sTw0f0sgMPh2VrSEB6XEfzJS4-r6A@mail.gmail.com>
References: <20170509135009.13751-1-Jason@zx2c4.com> <20170509135009.13751-6-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        kernel-hardening@lists.openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:48075 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751210AbdEIOKa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 10:10:30 -0400
In-Reply-To: <20170509135009.13751-6-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 9, 2017 at 3:50 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>                 num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;

(The next submission of this will take into account this + 1 here.
https://git.zx2c4.com/linux-dev/log/?h=jd/safe-skb-vec )
