From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/2] vxlan: Relax the MTU constraint on vxlan devices
Date: Thu, 7 Jan 2016 12:50:01 +0100
Message-ID: <20160107115001.GK32456@pox.localdomain>
References: <1452087186-12926-1-git-send-email-david@weave.works>
 <1452087186-12926-2-git-send-email-david@weave.works>
 <20160107112414.GH32456@pox.localdomain>
 <86lh81pqw5.fsf@weave.works>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Wragg <david@weave.works>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37713 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbcAGLuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 06:50:04 -0500
Received: by mail-wm0-f41.google.com with SMTP id f206so119252079wmf.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 03:50:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <86lh81pqw5.fsf@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/16 at 11:31am, David Wragg wrote:
> Thomas Graf <tgraf@suug.ch> writes:
> >> +	int max_mtu = 65535;
> >
> > This should probably be represented as a new const DEV_MAX_MTU which
> > can be used by veth, tun, and virtio as well instead of hardcoding
> > this separately in each driver.
> 
> I discovered IP_MAX_MTU in net/route.h after putting the patch together.
> Seems appropriate to use that?

That seems fine for both patch 1 and 2.
