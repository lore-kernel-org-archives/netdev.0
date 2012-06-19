From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 12:51:25 +0800
Message-ID: <CABa6K_FP=nTzpBJCN7QQ87_axsJ=hM9DLUbeNgBp-E+_ke2FKA@mail.gmail.com>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
 <CABa6K_Ge-Y1ne3iBcN1HSRN+G4bW6hSAHYFGKuA5QKW6CT3grQ@mail.gmail.com> <1340081276.7491.2228.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:37315 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348Ab2FSEvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:51:46 -0400
Received: by qafi31 with SMTP id i31so2313921qaf.1
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 21:51:45 -0700 (PDT)
In-Reply-To: <1340081276.7491.2228.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 19, 2012 at 12:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-06-19 at 12:43 +0800, Changli Gao wrote:
>
>> I am afraid that this lookup with hurt the performance of the
>> forwarding path. A knob?
>>
>
> ip_rcv() & ip_rcv_finish() in the forwarding path ?
>
>

Yes, the two routines are shared by both. I think you mean
ip_local_deliver() and ip_local_deliver_finish().

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
