From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/3] chelsio: more rx speedup
Date: Thu, 18 Jan 2007 22:05:48 -0500
Message-ID: <45B0358C.3090503@pobox.com>
References: <20061215190716.956791000@osdl.org> <4591912E.60402@pobox.com> <20070108112426.2a5e43fa@dxpl.pdx.osdl.net> <20070108112524.730e89f0@dxpl.pdx.osdl.net> <20070108112612.5f947357@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47692 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964782AbXASDFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 22:05:50 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20070108112612.5f947357@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Cleanup receive processing some more:
>    * do the reserve padding of skb during setup
>    * don't pass constants to get_packet
>    * do smart prefetch of skb
>    * make copybreak a module parameter
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

applied


