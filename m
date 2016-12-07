From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Wed, 7 Dec 2016 10:47:16 -0800
Message-ID: <CAA93jw7hcmkcyD=t4VRrQFfHk+n+EkSVgY6KFDq0_-DGpMADYw@mail.gmail.com>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, linux-mips@linux-mips.org,
        LKML <linux-kernel@vger.kernel.org>,
        WireGuard mailing list <wireguard@lists.zx2c4.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The openwrt tree has long contained a set of patches that correct for
unaligned issues throughout the linux network stack.

https://git.lede-project.org/?p=openwrt/source.git;a=blob;f=target/linux/ar71xx/patches-4.4/910-unaligned_access_hacks.patch;h=b4b749e4b9c02a74a9f712a2740d63e554de5c64;hb=ee53a240ac902dc83209008a2671e7fdcf55957a

unaligned access traps in the packet processing path on certain versions of
the mips architecture is horrifically bad. I had kind of hoped these
patches in some form would have made it upstream by now. (or the
arches that have the issue retired, I think it's mostly just mips24k)
