From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sun, 05 Dec 2010 10:13:48 -0500
Message-ID: <1291562028.2159.692.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <4CFA3F01.20109@gmail.com> <1291472889.2159.18.camel@mojatatu>
	 <1291474127.2159.35.camel@mojatatu> <20101204154007.GA1981@del.dom.local>
	 <1291478881.2159.70.camel@mojatatu> <20101204165609.GB1981@del.dom.local>
	 <AANLkTimnejoONxGqusiYVWOKbcy2yqbpFH-XyzgG0=87@mail.gmail.com>
	 <AANLkTimMvb187gOFzZZgWuzWJkk_Z3AOZaoc6M76H-e=@mail.gmail.com>
	 <1291559402.2159.687.camel@mojatatu>
	 <AANLkTimXDTTNcrFPngzEuoDGVgojtBxUZQPOMiSA7yNw@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:47435 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155Ab0LEPOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 10:14:05 -0500
Received: by gwb20 with SMTP id 20so5852351gwb.1
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 07:14:03 -0800 (PST)
In-Reply-To: <AANLkTimXDTTNcrFPngzEuoDGVgojtBxUZQPOMiSA7yNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-05 at 22:40 +0800, Changli Gao wrote:
> On Sun, Dec 5, 2010 at 10:30 PM, jamal <hadi@cyberus.ca> wrote:

> > - we use tasklets. When we  reschedule we can end up on a differrent
> > cpu.
> 
> The tasklets always been scheduled to the current CPU unless it has
> been schedule already on the other CPU.

I dont think this can be guaranteed - So the potential of packet 
reordering exists.

> I keep using tasklet. The attachment is the alpha version.

>From quick glance I dont see any technicalities - just the 
reordering concern.

cheers,
jamal



