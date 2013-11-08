From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: fix a UFO regression
Date: Fri, 08 Nov 2013 12:57:29 -0800
Message-ID: <1383944249.16391.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuyuHagy7j+fi8RnKjZNBnwYHhxfed508HyXLfHp-e634w@mail.gmail.com>
		 <527C877D.3080309@gmail.com>
	 <1383913124.9412.223.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527D478E.4020607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:39471 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757521Ab3KHU5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:57:34 -0500
Received: by mail-qa0-f46.google.com with SMTP id j7so2167817qaq.12
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 12:57:33 -0800 (PST)
In-Reply-To: <527D478E.4020607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 12:20 -0800, Sridhar Samudrala wrote:

> I am seeing almost similar results with both Emulex and Intel 10Gb NICs 
> at both sender and receiver.
> >
> > If you use GRE instead of VXLAN, do you get any difference in speed ?
> With GRE, i am seeing slightly better results. 3.2Gb/s compared to 
> 1.8Gb/s with vxlan.

Thanks, it seems to point a bottleneck at receiver, as we have GRO
support for GRE, but not yet for VXLAN.
