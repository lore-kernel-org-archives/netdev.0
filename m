From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] virtio_net: fix PAGE_SIZE > 64k
Date: Tue, 24 Jan 2017 15:09:59 -0500 (EST)
Message-ID: <20170124.150959.1708982899683381291.davem@davemloft.net>
References: <1485197869-11350-1-git-send-email-mst@redhat.com>
        <20170124.144227.2017106704873029028.davem@davemloft.net>
        <20170124215214-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124215214-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 24 Jan 2017 21:53:13 +0200

> I didn't realise. Why can't we? I thought that adjust_header is an
> optional feature that userspace can test for, so no rush.

No, we want the base set of XDP features to be present in all drivers
supporting XDP.
