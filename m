From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC][PATCH 1/3] Introduce the net_device_ops structure.
Date: Fri, 4 Apr 2008 08:14:58 -0700
Message-ID: <20080404081458.197f58ba@extreme>
References: <47F63681.1030603@openvz.org>
	<47F636EC.5070506@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35018 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129AbYDDPPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 11:15:06 -0400
In-Reply-To: <47F636EC.5070506@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Apr 2008 18:10:52 +0400
Pavel Emelyanov <xemul@openvz.org> wrote:

> And fill it with copied from net_device.
> 
> Also make newly created devices be assigned to the 
> (currently empty) nd_default_ops.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks, I started this a while back but never got to the bottom.
Please use const where possible (on dev->nd_ops) and in devices.
