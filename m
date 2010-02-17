From: jamal <hadi@cyberus.ca>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Wed, 17 Feb 2010 18:07:18 -0500
Message-ID: <1266448038.17794.135.camel@bigi>
References: <20100217191718.GA5256@x200>  <1266442972.17794.51.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:37360 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079Ab0BQXHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 18:07:21 -0500
Received: by qyk38 with SMTP id 38so2456162qyk.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 15:07:19 -0800 (PST)
In-Reply-To: <1266442972.17794.51.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 16:42 -0500, jamal wrote:

> I will try to reproduce it in about an hour. Do you have
> anything like selinux being used etc?

I have reproduced it - thanks Alexey. When you flush
an empty table, the time goes up from about 1.5s
to 3 secs with pfkey. You also see the EAGAIN for
each flush ...
I am going to dig a little more ..

cheers,
jamal

