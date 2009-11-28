From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 11:04:38 -0500
Message-ID: <1259424278.3864.16.camel@bigi>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu>  <4B1145F1.3090704@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:58962 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbZK1QEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 11:04:36 -0500
Received: by qyk32 with SMTP id 32so948753qyk.4
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 08:04:41 -0800 (PST)
In-Reply-To: <4B1145F1.3090704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-11-28 at 16:46 +0100, Patrick McHardy wrote:

> 
> The root cause seems to be an invalid assumption, marks are often not
> used in a symetric fashion as required by RPF.

The only assumption is: if you set set up a mark on incoming, you are
asking the reverse validation that is to be used to consider that mark.

This has nothing to do with RPF really;-> RPF is off. There is a legit
bug in the old setup that has a table programmed with a route that is
not unicast. 

> Since this patch has already proven to break existing setups, I think
> it should be reverted or the behaviour made optional with a default to
> off.

I disagree. What other setup is broken? ;->

cheers,
jamal

