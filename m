From: David Miller <davem@davemloft.net>
Subject: Re: Softirqs without captured packets
Date: Wed, 06 Mar 2013 14:40:44 -0500 (EST)
Message-ID: <20130306.144044.15394529904514435.davem@davemloft.net>
References: <CALZVapmKbqcamTYTEhoerRUPpjsaLJqoTo84Fqmz+aUWWTmh2g@mail.gmail.com>
	<1361542281.3683.3.camel@edumazet-glaptop>
	<CALZVapniE32NfuOjmfDd7DmVHxGLmMTunJu2CxBHRsyoE1Kqaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: javierdo1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab3CFTkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:40:46 -0500
In-Reply-To: <CALZVapniE32NfuOjmfDd7DmVHxGLmMTunJu2CxBHRsyoE1Kqaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Domingo <javierdo1@gmail.com>
Date: Wed, 6 Mar 2013 18:20:35 +0100

> Another question, that is a little related, in tg3, it deactivates
> napi, when it has a TX_RECOVERY_PENDING, what does that flag mean?

It means that we are resetting the device.
