From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: virtio pull for 4.5 (was Re: [PULL] virtio: barrier rework+fixes)
Date: Mon, 18 Jan 2016 17:01:26 -0800
Message-ID: <CA+55aFyh_1Lpp4U2wsFJQu_4PmSBD=36YeAhQN94L4GUhQrb2Q@mail.gmail.com>
References: <20160113182855-mutt-send-email-mst@redhat.com>
	<20160118152028-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: KVM list <kvm@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Rafael Aquini <aquini@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Bjorn Andersson <bjorn.andersson@sonymobile.com>,
	Boqun Feng <boqun.feng@gmail.com>,
	=?UTF-8?B?Q2M6IGRhdmVAc3Rnb2xhYnMubmV0LCBkYXZlbUBkYXZlbWxvZnQubmV0LCBkYXZpZC52cmFiZWxAY2l0?=
	 =?UTF-8?B?cml4LmNvbSwgZGJ1ZXNvQHN1c2UuZGUsIGhlaWtvLmNhcnN0ZW5zQGRlLmlibS5jb20sIGphbWVzLmhv?=
	 =?UTF-8?B?Z2FuQGltZ3RlYy5jb20sIGpvZUBwZXJjaGVzLmNvbSwganVsaWFuLmNhbGFieUBnbWFpbC5jb20sIGxp?=
	 =?UTF-8?B?bnV4LWFyY2hAdmdlci5rZXJuZWwub3JnLCBsaW51eEBhcm0ubGludXgub3JnLnVrLCBtaW5jaGFuQGtl?=
	 =?UTF-8?B?cm5lbC5vc
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35304 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599AbcASBB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 20:01:27 -0500
In-Reply-To: <20160118152028-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2016 at 5:21 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> Hi Linus,
> Just making sure nothing's wrong with this pull request.
> If there's an issue, pls let me know!

It was just pulled because I wasn't 100% sure I wanted the extra
indirection. Oh well, pulled now.

One question:

 - the arch/sh/ part of the pacth looks dubious. Why does it do that

     #define smp_store_mb(var, value) __smp_store_mb(var, value)

   despite the commit log saying it's done by asm-generic?

I haven't pushed out yet, my allmodconfig sanity-check build is still going..

                      Linus
