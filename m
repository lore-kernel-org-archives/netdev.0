From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] Fix station address detection in smc
Date: Fri, 15 Feb 2008 10:53:11 -0500
Message-ID: <47B5B567.9060501@pobox.com>
References: <47B38F8F.6060408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-pcmcia@lists.infradead.org, Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52914 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753425AbYBOPxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 10:53:39 -0500
In-Reply-To: <47B38F8F.6060408@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Ebbert wrote:
> Megahertz EM1144 PCMCIA ethernet adapter needs special handling
> because it has two VERS_1 tuples and the station address is in
> the second one. Conversion to generic handling of these fields
> broke it. Reverting that fixes the device.
> 
>   https://bugzilla.redhat.com/show_bug.cgi?id=233255
> 
> Thanks go to Jon Stanley for not giving up on this one until the
> problem was found.
> 
> Signed-off-by: Chuck Ebbert <cebbert@redhat.com>
> 
> ---
> 
> This was broken for over a year before the problem was found...

applied


