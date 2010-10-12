From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: kvm networking todo wiki
Date: Tue, 12 Oct 2010 19:38:11 +0200
Message-ID: <20101012173811.GA30997@redhat.com>
References: <20100921161124.GC22845@redhat.com>
 <4C9A873E.6010403@us.ibm.com>
 <20100926112112.GB18408@redhat.com>
 <AANLkTikzU6g2pYKoyXOWfGPE64VZusPaYdn+TQ14tE7_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>, sri@linux.vnet.ibm.com,
	Anthony Liguori <anthony@codemonkey.ws>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Shirley Ma <mashirle@us.ibm.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>, jdike@linux.intel.com,
	herbert@gondor.hengli.com.au, lmr@redhat.com, akong@redhat.com,
	kvm@vger.kernel.org, qemu-devel@nongnu.org, netdev@vger.kernel.org,
	mjt@tls.msk.ru
To: Dragos Tatulea <dragos.tatulea@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikzU6g2pYKoyXOWfGPE64VZusPaYdn+TQ14tE7_@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 10, 2010 at 01:37:45PM +0200, Dragos Tatulea wrote:
> Hi,
> 
> > More importantly: anyone's going to work on this?
> 
> I'd like to work on this. Might need some assistance though.
> 
> Thanks,
> Dragos

BTW, as in some situations hardware might not be able satisfy
requirements, a subset of this item would be to expose whatever macvtap
is capable of, to the guest.  E.g. if mac can not be changed we could at
least query the mac, something that would be convenient as noted by mjt
in an irc chat.

To enable migration we'd then need a set of flags to limit this to a least
common denominator on a given network.

-- 
MST
