From: jamal <hadi@cyberus.ca>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Thu, 18 Feb 2010 15:53:36 -0500
Message-ID: <1266526416.3879.109.camel@bigi>
References: <20100217191718.GA5256@x200> <1266442972.17794.51.camel@bigi>
	 <1266448038.17794.135.camel@bigi> <1266449529.17794.157.camel@bigi>
	 <20100218185510.GA18829@x200>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:37628 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239Ab0BRUxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 15:53:38 -0500
Received: by qyk38 with SMTP id 38so3211228qyk.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 12:53:38 -0800 (PST)
In-Reply-To: <20100218185510.GA18829@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-18 at 20:55 +0200, Alexey Dobriyan wrote:

> I'd expect flushing empty SAD/SPD to be exact nops. :^)

Agree - that is a better alternative.
I was hoping returning an error code of 0 will do that.
But that triggers the EAGAIN you saw. It doesnt trigger
an EAGAIN for the netlink side (and it is a nop there).
Let me look at it. Clearly the EAGAIN is causing the 
latency.

cheers,
jamal

