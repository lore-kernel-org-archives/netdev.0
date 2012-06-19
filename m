From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 06:47:56 +0200
Message-ID: <1340081276.7491.2228.camel@edumazet-glaptop>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
	 <CABa6K_Ge-Y1ne3iBcN1HSRN+G4bW6hSAHYFGKuA5QKW6CT3grQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62867 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab2FSEsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:48:01 -0400
Received: by eaak11 with SMTP id k11so1808616eaa.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 21:48:00 -0700 (PDT)
In-Reply-To: <CABa6K_Ge-Y1ne3iBcN1HSRN+G4bW6hSAHYFGKuA5QKW6CT3grQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 12:43 +0800, Changli Gao wrote:

> I am afraid that this lookup with hurt the performance of the
> forwarding path. A knob?
> 

ip_rcv() & ip_rcv_finish() in the forwarding path ?
