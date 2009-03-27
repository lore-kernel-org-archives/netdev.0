From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-2.6 PATCH 1/9] Neterion: Driver help file
Date: Fri, 27 Mar 2009 19:09:24 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77051BEB23@nekter>
References: <1238194447.5516.374.camel@flash> <20090327.154628.195613387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:58509 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755157AbZC0XJ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 19:09:27 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090327.154628.195613387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm not apply any of this patch set.
> 
> > +4) Performance Suggestions:
> > +---------------------------
> > +
> > +- Set MTU to maximum - 9000 for switch setup, 9600 for
back-to-back.
> > +For MTU 1500:
> > +-------------
> > +### IPV4 specific settings
> > +# turns TCP timestamp support off, default 1, reduces CPU use
> > +$sysctl -w net.ipv4.tcp_timestamps = "0"
> 
> You have got to be kidding me.
> 
> I see this garbage in the "tuning suggestions" sections of
> various manuals of proprietary products for Linux.
> 
> But there is no way I'm letting this junk slip into Linux proper too.
> 
> All of these suggestions are ill founded, have side effects that are
> not even passively mentioned in these "suggestions", and are even
> dangerous.
> 
> Do you even know the security implications of turning off TCP
timestamps?
> Do you know or even feel the need to mention the performance
implications
> over long haul networks of turning timestamps off?
[Ram] I should have removed this suggestion. We usually suggest that
timestamps (and SACKs) be left enabled. We'll remove this section. Is it
ok I resend just this patch instead of the whole series?

> 
> If the default sysctl parameters are not correct, let's fix them
instead
> of telling every user how to break their system with "tweaks".
[Ram] I'll send some suggestions for the sysctl parameters in a separate
thread.

Ram
