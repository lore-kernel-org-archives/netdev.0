From: Shirley Ma <mashirle@us.ibm.com>
Subject: RE: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Wed, 04 Aug 2010 10:09:05 -0700
Message-ID: <1280941745.3391.15.camel@localhost.localdomain>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
	 <F2E9EB7348B8264F86B6AB8151CE2D791BAB307158@shsmsx502.ccr.corp.intel.com>
	 <1280505112.9058.31.camel@localhost.localdomain>
	 <201007311130.17000.arnd@arndb.de>
	 <1A42CE6F5F474C41B63392A5F80372B228FCE7B1@shsmsx501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Dong, Eddie" <eddie.dong@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:45788 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815Ab0HDRJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 13:09:13 -0400
In-Reply-To: <1A42CE6F5F474C41B63392A5F80372B228FCE7B1@shsmsx501.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eddie,

On Wed, 2010-08-04 at 10:06 +0800, Dong, Eddie wrote:
> But zero-copy is a Linux generic feature that can be used by other
> VMMs as well if the BE service drivers want to incorporate.  If we can
> make mp device VMM-agnostic (it may be not yet in current patch), that
> will help Linux more.

First other VMMs support tun/tap which provides most funcs but not zero
copy.

Second mp patch only supports zero copy for vhost now, macvtap zero copy
will not be used by vhost only.

Third, the current mp device doesn't fallback to copy when failure.

So you can extend mp device to support all funcs, but the usage/funcs
will be similar with macvtap, then either mp device will replace macvtap
in the future with similar funcs or we can use enhance macvtap to
support zero copy. It is not necessary to have both in Linux.

I think it's better to implement zero copy in macvtap, tun/tap instead
of creating a new mp device.

Thanks
Shirley

