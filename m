From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sun, 05 Dec 2010 10:31:33 -0500
Message-ID: <1291563093.2159.694.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <4CFA3F01.20109@gmail.com> <1291472889.2159.18.camel@mojatatu>
	 <1291474127.2159.35.camel@mojatatu> <20101204154007.GA1981@del.dom.local>
	 <1291478881.2159.70.camel@mojatatu> <20101204165609.GB1981@del.dom.local>
	 <AANLkTimnejoONxGqusiYVWOKbcy2yqbpFH-XyzgG0=87@mail.gmail.com>
	 <AANLkTimMvb187gOFzZZgWuzWJkk_Z3AOZaoc6M76H-e=@mail.gmail.com>
	 <1291559402.2159.687.camel@mojatatu>
	 <AANLkTimXDTTNcrFPngzEuoDGVgojtBxUZQPOMiSA7yNw@mail.gmail.com>
	 <1291562028.2159.692.camel@mojatatu>
	 <AANLkTimLd=d94Cnh8dsX8HFFeYM4mBGH1gpK+p3YT-hm@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:44831 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155Ab0LEPbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 10:31:50 -0500
Received: by gxk19 with SMTP id 19so6097673gxk.11
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 07:31:49 -0800 (PST)
In-Reply-To: <AANLkTimLd=d94Cnh8dsX8HFFeYM4mBGH1gpK+p3YT-hm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-05 at 23:22 +0800, Changli Gao wrote:

> The current implementation can guarantee it. However, I can't find
> documentation about this 'feature', but I think this behavior should
> not be changed in future since maybe some call sites relay on it.

When you think you are in good shape - please add some debug hooks
so we can verify this especially under a huge traffic input and
I will test it (thats what end of year holidays are for).

cheers,
jamal

