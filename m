From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: multi producer / multi consumer lock-free queue with ptr_ring
Date: Wed, 4 Oct 2017 13:18:24 +0200
Message-ID: <CAHmME9qPYL-wzyX0Q7RG7Uk9kAeWbzNN5=0YrmbniUR2O3rSxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>,
        Samuel Holland <samuel@sholland.org>,
        WireGuard mailing list <wireguard@lists.zx2c4.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Michael,

Thanks for your work on ptr_ring.h. I'm interested in using it, but in
a multi-producer, multi-consumer context. I realize it's been designed
for a single-producer, single-consumer context, and thus uses a
spinlock. I'm wondering if you'd be happy to receive patches that
implement things in a lock-free way, in order to make the data
structure more broadly usable.

In case you're curious, this would be used for the multi-core
algorithms in WireGuard.

Thanks,
Jason
