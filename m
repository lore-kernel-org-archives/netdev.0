From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Tue, 23 Aug 2011 13:19:36 +0930
Message-ID: <87bovg4wj3.fsf@rustcorp.com.au>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com> <20110819152335.GA19489@redhat.com> <87hb5a5m3x.fsf@rustcorp.com.au> <20110822083613.GA18556@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110822083613.GA18556@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Aug 2011 11:36:13 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> Yes. Or maybe 'WHEN' - since if MSI-X is disabled again, it moves back.
> Let's update the spec to make it clearer?

I left the language as is, but added a footnote at the end of the
sentence:

If MSI-X is enabled for the device, two additional fields immediately
follow this header:
[footnote: ie. once you enable MSI-X on the device, the other
           fields move. If you turn it off again, they move back!]

Thanks,
Rusty.
