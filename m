From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH net-2.6] llc: fix a device refcount imbalance
Date: Thu, 09 Dec 2010 05:46:35 +0200
Message-ID: <1291866395.7792.31.camel@maxim-laptop>
References: <1291537161.2806.109.camel@edumazet-laptop>
	 <1291548233.2806.212.camel@edumazet-laptop>
	 <1291550606.2806.237.camel@edumazet-laptop>
	 <20101208.095920.229730656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	opurdila@ixiacom.com, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:39221 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab0LIDql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 22:46:41 -0500
Received: by fxm18 with SMTP id 18so1892897fxm.2
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 19:46:40 -0800 (PST)
In-Reply-To: <20101208.095920.229730656.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-08 at 09:59 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 05 Dec 2010 13:03:26 +0100
> 
> > [PATCH net-2.6] llc: fix a device refcount imbalance
> > 
> > commit abf9d537fea225 (llc: add support for SO_BINDTODEVICE) added one
> > refcount imbalance in llc_ui_bind(), because dev_getbyhwaddr() doesnt
> > take a reference on device, while dev_get_by_index() does.
> > 
> > Fix this using RCU locking. And since an RCU conversion will be done for
> > 2.6.38 for dev_getbyhwaddr(), put the rcu_read_lock/unlock exactly at
> > their final place.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied and queued up for -stable.

Hi,

Could I kindly ask if my patch is accepted?

Best regards,
	Maxim Levitsky

