From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Mon, 7 Nov 2011 13:41:42 -0800
Message-ID: <20111107134142.05d997a5@nehalam.linuxnetplumber.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
	<1320512055-1231037-2-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34333 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906Ab1KGVlp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 16:41:45 -0500
In-Reply-To: <1320512055-1231037-2-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2011 17:54:14 +0100
David Lamparter <equinox@diac24.net> wrote:

> - *	@h_vlan_proto: ethernet protocol (always 0x8100)
> + *	@h_vlan_proto: ethernet protocol (0x8100, 0x88a8, 0x9x00)

It seems this patch is mixing stacked vlan's and the ability to
set ethernet protocol field. Aren't the two capabilities really
separate protocol extensions?
