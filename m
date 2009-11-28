From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 14:26:08 -0500
Message-ID: <1259436368.3864.43.camel@bigi>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu> <1259423157.3864.9.camel@bigi>
	 <20091128185019.GA12264@sch.bme.hu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:49428 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbZK1T0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 14:26:04 -0500
Received: by qyk32 with SMTP id 32so993195qyk.4
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 11:26:10 -0800 (PST)
In-Reply-To: <20091128185019.GA12264@sch.bme.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-11-28 at 19:50 +0100, KOVACS Krisztian wrote:

> Well, the only route we're interested in is the following (see
> Documentation/networking/tproxy.txt for the details):
> 
> ip route add local 0.0.0.0/0 dev lo table 100
> 

ip route add unicast 0.0.0.0/0 dev lo table 100
would work.

> Adding a unicast route is not really an option, 

Can you explain this part?

cheers,
jamal

