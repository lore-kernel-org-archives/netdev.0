From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] vhost-net: add module alias
Date: Wed, 11 Jan 2012 11:07:47 +0400
Message-ID: <4F0D3543.7020401@msgid.tls.msk.ru>
References: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11.01.2012 08:54, Stephen Hemminger wrote:
> By adding the a module alias, programs (or users) won't have to explicitly
> call modprobe. Vhost-net will always be available if built into the kernel.
> It does require assigning a permanent minor number for depmod to work.
> Choose one next to TUN since this driver is related to it.

Why do you think a statically-allocated device number will do any good
at all?  Static /dev is gone almost completely, at least on the systems
where whole virt stuff makes any sense, so you don't have pre-created
vhost-net device anymore, and hence this allocation makes no sense.
Just IMHO anyway.

Thanks,

/mjt
