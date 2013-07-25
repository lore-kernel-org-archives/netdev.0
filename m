From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/3] tuntap: allow overriding ethtool driver
 info
Date: Wed, 24 Jul 2013 17:16:17 -0700
Message-ID: <20130724171617.53a48d24@nehalam.linuxnetplumber.net>
References: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
	<20130724161325.38404ed3@nehalam.linuxnetplumber.net>
	<1374709687.1732.46.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:42436 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685Ab3GYAQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:16:21 -0400
Received: by mail-pa0-f49.google.com with SMTP id bi5so1280722pad.36
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 17:16:20 -0700 (PDT)
In-Reply-To: <1374709687.1732.46.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Jul 2013 00:48:07 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2013-07-24 at 16:13 -0700, Stephen Hemminger wrote:
> > This patch adds new ioctl to allow setting the ethtool information
> > returned by the TUN device. This is useful when using tun device as a surrogate
> > for hardware or other software emulation.
> 
> I don't like this idea.  Which tools are you trying to fool?  How does
> this work when you don't implement any driver-specific behaviour (e.g.
> SIOCDEVPRIVATE) they expect?

We use surrogate interfaces in user mode application and want to
display different information for these than the normal TUN device.
