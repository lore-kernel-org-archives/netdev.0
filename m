From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_mirred: don't go back.
Date: Wed, 11 Nov 2009 17:23:24 +0800
Message-ID: <412e6f7f0911110123kfcca087gc3561bdc018f4e9f@mail.gmail.com>
References: <4AF7B9F4.6010507@gmail.com> <1257751376.8009.2.camel@bigi>
	 <412e6f7f0911090031j16ab9c73o47f4d4d3ffd9be3a@mail.gmail.com>
	 <1257764086.6246.1.camel@bigi>
	 <412e6f7f0911090433j2b270663ycdf277110fbc6bac@mail.gmail.com>
	 <1257838834.3647.4.camel@bigi>
	 <412e6f7f0911100050k39920adfl1ab70e345269833a@mail.gmail.com>
	 <1257927097.4685.4.camel@bigi>
	 <412e6f7f0911110044i22c28ab6pa3a3691c014e76a8@mail.gmail.com>
	 <1257930232.4685.20.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:65410 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbZKKJXS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 04:23:18 -0500
Received: by pzk26 with SMTP id 26so632920pzk.4
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 01:23:24 -0800 (PST)
In-Reply-To: <1257930232.4685.20.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2009 at 5:03 PM, jamal <hadi@cyberus.ca> wrote:
> On Wed, 2009-11-11 at 16:44 +0800, Changli Gao wrote:
>
> I open a socket and I install a filter to mirror or redirect to this
> socket. It is possible to do it today if you use tun device; thats
> why i have never been motivated to do it.
>

PF_PACKET can mirror to socket. And with the help of ingress polices,
it can emulate redirection too. Am I right?


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
