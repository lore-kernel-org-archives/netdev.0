From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [Ipw2100-devel] ipw2100: race between isr_indicate_associated and rx path
Date: Tue, 24 Feb 2009 08:36:42 +0100
Message-ID: <200902240836.42948.helmut.schaa@gmail.com>
References: <200901211734.48625.helmut.schaa@gmail.com> <200902231138.58067.helmut.schaa@gmail.com> <20090223180801.GA29290@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Zhu, Yi" <yi.zhu@intel.com>,
	"ipw2100-devel@lists.sourceforge.net"
	<ipw2100-devel@lists.sourceforge.net>
To: Jouni Malinen <j@w1.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f167.google.com ([209.85.220.167]:51400 "EHLO
	mail-fx0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbZBXIkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 03:40:06 -0500
Received: by fxm11 with SMTP id 11so2572898fxm.13
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2009 00:40:03 -0800 (PST)
In-Reply-To: <20090223180801.GA29290@jm.kir.nu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 23. Februar 2009 schrieb Jouni Malinen:
> On Mon, Feb 23, 2009 at 11:38:57AM +0100, Helmut Schaa wrote:
> 
> > Jouni, would you accept a patch for wpa_supplicant that adds some retries
> > to l2_packet_send when the network stack returns an error?

[...]

> I did not fully understand the details of the issue and why noop_qdisc
> is used at the point when a frame is delivered to user space, so I may
> be missing some details here. Anyway, I would highly prefer the kernel
> to avoid delivering EAPOL frames into user space if it is not ready to
> transmit a response to them.

Sounds reasonable to me.

Helmut
