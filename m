From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw MAC address
Date: Wed, 12 Feb 2014 20:35:31 -0800
Message-ID: <CAB=NE6WtKf_imDkcyLa_TDT4ajEeBZv5x5b4Vsd+nheEmGt5sA@mail.gmail.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
 <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
 <1392108205.22033.16.camel@dagon.hellion.org.uk> <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
 <1392203708.13563.50.camel@kazak.uk.xensource.com> <CAB=NE6WFDWW1faoCYJP9zh6rPPvET+dbHxjHnGkYXtRx6z2LOQ@mail.gmail.com>
 <CAB=NE6Vf4KHyMGiGZuuvZ8uWhw51UXbhHPt5RxqZaJbLHOU71w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6Vf4KHyMGiGZuuvZ8uWhw51UXbhHPt5RxqZaJbLHOU71w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 12, 2014 at 8:27 PM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> I have a test patch that now works that restricts xen-netback from
> getting any IPv4 and IPv6 addresses, and disables multicast. With this
> set in place the xen-frontend still gets IPv4 and IPv6 addresses and
> Multicast still works. This was tested under a shared physical
> environment, I'll have to test NAT next, and also see if we can enable
> this as an option for KVM for their TAP 'backend' interfaces.

Also perhaps a silly question, as I haven't yet looked carefully into
the qemu TAP usage / requirement yet, but has anyone considered just
having a dma-buf agent for us in userspace ? That'd remove any
redundant interfaces and do let qemu do DMA directly.

  Luis
