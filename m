From: Patrick McHardy <kaber@trash.net>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 15:00:01 +0200
Message-ID: <463B2E51.90808@trash.net>
References: <5484.1178282928@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54537 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924AbXEDNAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 09:00:38 -0400
In-Reply-To: <5484.1178282928@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells wrote:
> I would like to determine through which interface packets sent to a particular
> UDP destination will go through, and so determine the MTU size for that
> interface.  Can anyone suggest a good way of doing this from within the
> kernel?


Do a route lookup (ip_route_output_key), then either use dst_mtu to get
the PMTU value or dst->dev in case you really want the device's MTU.
