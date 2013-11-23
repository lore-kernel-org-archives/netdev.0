From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH IPROUTE] ip: Add HSR support
Date: Fri, 22 Nov 2013 17:33:34 -0800
Message-ID: <20131122173334.0ae81887@nehalam.linuxnetplumber.net>
References: <527D3CCC.3020609@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:52687 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911Ab3KWBdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 20:33:38 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so1981811pde.6
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 17:33:37 -0800 (PST)
In-Reply-To: <527D3CCC.3020609@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Nov 2013 20:34:36 +0100
Arvid Brodin <arvid.brodin@xdin.com> wrote:

> This patch adds basic support for High-Availability Seamless
> Redundancy (HSR) network devices.
> 
> Signed-off-by: Arvid Brodin <arvid.brodin@xdin.com>

Will not apply to current iproute source. The header files have been updated
to be from current upstream (linus), and the IFLA_HSR doesn't match.

Please fix, and resubmit. Note, for iproute2 the header files are updated
perodically by using headers from kernel source (sanitized).

usr/include/linux/if_link.h


/* HSR section */

enum {
        IFLA_HSR_UNSPEC,
        IFLA_HSR_SLAVE1,
        IFLA_HSR_SLAVE2,
        IFLA_HSR_MULTICAST_SPEC,
        __IFLA_HSR_MAX,
};

#define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
