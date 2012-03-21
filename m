From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: locking in net_device_ops callbacks
Date: Wed, 21 Mar 2012 16:00:13 -0700
Message-ID: <20120321160013.065e2e3f@nehalam.linuxnetplumber.net>
References: <471DE477E2B1F549A58F3A14A27180BE014357@HQ-EX01.bytemobile.com>
	<1332359899.2553.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Haran <jharan@bytemobile.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35304 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757242Ab2CUXAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2012 19:00:16 -0400
In-Reply-To: <1332359899.2553.17.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another part of this is that it is not allowed to change many settings
like name, mac address or master relationship if device is UP.
