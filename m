From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iputils: ping by mark
Date: Sat, 17 Oct 2009 08:30:35 -0400
Message-ID: <1255782635.11213.7.camel@dogo.mojatatu.com>
References: <1255381558.5406.33.camel@dogo.mojatatu.com>
	 <7e84ed60910161405i2ce46053m9858b7f1c086e6b7@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Rob.Townley@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:39269 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbZJQMdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 08:33:37 -0400
Received: by qyk32 with SMTP id 32so1972527qyk.4
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2009 05:33:41 -0700 (PDT)
In-Reply-To: <7e84ed60910161405i2ce46053m9858b7f1c086e6b7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-16 at 16:05 -0500, Rob Townley wrote:

> Would this make it easier to ping multiple gateways 

yes. 
You need to set your policy routing accordingly to have a different
gateway for the same destination and then use the -m to select the
routing table..

> so if one goes
> down, it is taken almost out of the routing table until it comes back
> up.

I am not sure i followed or see any relation to the first part of your
question.
Ive never heard of routing table entries automagically being taken down
until something comes up. You could do it probably by writting a user
space daemon.

cheers,
jamal


