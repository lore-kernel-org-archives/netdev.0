From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/7] Topcliff GbE: Add The Main code [1/3]
Date: Fri, 23 Apr 2010 08:26:24 -0700
Message-ID: <20100423082624.147de667@nehalam>
References: <002d01cae2dd$1f6e42d0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "NETDEV" <netdev@vger.kernel.org>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38047 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755844Ab0DWP0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 11:26:42 -0400
In-Reply-To: <002d01cae2dd$1f6e42d0$66f8800a@maildom.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Apr 2010 20:56:25 +0900
"Masayuki Ohtake" <masa-korg@dsn.okisemi.com> wrote:

Even though the patch was sent as an attachment, long lines were
wrapped.

Do you want this to go directly to kernel, or do you want help
fixing coding issues by submitting to staging tree?

The code uses a comment style that is kind of like the existing
docbook comment style; why not convert it to use the official
docbook style for examples look at other kernel code:
/**
 *	dev_alloc_skb - allocate an skbuff for receiving
 *	@length: length to allocate
 *
 *	Allocate a new &sk_buff and assign it a usage count of one. The
 *	buffer has unspecified headroom built in. Users should allocate
 *	the headroom they think they need without accounting for the
 *	built in space. The built in space is used for optimisations.
 *
 *	%NULL is returned if there is no free memory. Although this function
 *	allocates memory it can be called from an interrupt.
 */

The code is also indented with a non-standard indentation format.
Please read Documentation/CodingStyle.  Indentation is supposed
to be 4 characters (and using tabs of 8 characters).


The PCI device table could be changed to:

static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
    { PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOH1_GBE) },
    { 0 }
};
Also PCI_DEVICE_ID_INTEL_IOH1_GBE is not defined anywhere I can see.
