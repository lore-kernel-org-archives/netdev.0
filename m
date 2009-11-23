From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 0/1] Defer skb allocation for both mergeable buffers
 and big packets in virtio_net
Date: Mon, 23 Nov 2009 08:51:50 +0000
Message-ID: <1258966310.14708.11.camel@blaa>
References: <1258697359.7416.14.camel@localhost.localdomain>
	 <200911231123.18898.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200911231123.18898.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-11-23 at 11:23 +1030, Rusty Russell wrote:
> I'd like to drop big packet support from our driver, but I don't know
> how many kvm hosts will not offer mergable rx bufs yet.  Anthony?

Mergeable rx bufs were first added in kvm-80 and qemu-0.10.0

So e.g., it's in Fedora since Fedora 11 and RHEL since 5.4

Cheers,
Mark.

