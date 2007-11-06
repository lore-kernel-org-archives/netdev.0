From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][IPV4] Consolidate the ip cork destruction in
 ip_output.c
Date: Mon, 05 Nov 2007 21:03:36 -0800 (PST)
Message-ID: <20071105.210336.29572904.davem@davemloft.net>
References: <472B4A76.2040801@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750878AbXKFFDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 00:03:37 -0500
In-Reply-To: <472B4A76.2040801@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 02 Nov 2007 19:04:06 +0300

> The ip_push_pending_frames and ip_flush_pending_frames do the
> same things to flush the sock's cork. Move this into a separate
> function and save ~80 bytes from the .text
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
