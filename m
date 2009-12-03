From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Thu, 03 Dec 2009 08:53:18 -0500
Message-ID: <1259848398.3766.43.camel@bigi>
References: <1259585129.3992.13.camel@nienna.balabit>
	 <1259589577.873.30.camel@bigi> <1259674488.3168.45.camel@bigi>
	 <20091202.223117.228943068.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hidden@balabit.hu, hidden@sch.bme.hu, kaber@trash.net,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:55530 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756136AbZLCNxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:53:16 -0500
Received: by vws30 with SMTP id 30so608358vws.33
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 05:53:22 -0800 (PST)
In-Reply-To: <20091202.223117.228943068.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BTW, it should be noted that the change from Patrick to fib_validate
which allows to accept local routes from will also solve this problem.
My suggestion below is to restore old expected behavior..

cheers,
jamal
 
On Wed, 2009-12-02 at 22:31 -0800, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Tue, 01 Dec 2009 08:34:48 -0500
> 
> > On Mon, 2009-11-30 at 08:59 -0500, jamal wrote:
> > 
> >> [I could move the check into fib_validate, but that would punish other
> >> users with a few extra cycles]. 
> > 
> > As in the following patch (gleaned from Patrick's patch on send to self)
> 
> Tproxy folks, please have a look at Jamal's patch, thanks.
> --


