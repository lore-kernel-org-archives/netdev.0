From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/3] tuntap: allow changing ethtool speed (v2)
Date: Thu, 25 Jul 2013 00:40:50 +0100
Message-ID: <1374709250.1732.40.camel@bwh-desktop.uk.level5networks.com>
References: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62316 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3GXXky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:40:54 -0400
In-Reply-To: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 16:11 -0700, Stephen Hemminger wrote:
> The data reported by the ethtool interface for tun/tap devices is
> artificial. The default speed is 10Mbit. Virtual interfaces are often
> faster than this nowadays, so the observed bandwidth may exceed the
> available bandwidth. This patch allows an administrator to change the
> available bandwidth as reported by ethtool.
> 
> Signed-off-by: Helmut Grohne <h.grohne@cygnusnetworks.de>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---
> v2 - allow setting duplex as well, fix patch formatting

It's logically full duplex so this doesn't make sense to me.

>      ignore other settings in set
[...]

No, please never do that in ethtool_ops::set_settings.  Setting
unsupported values is an error.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
