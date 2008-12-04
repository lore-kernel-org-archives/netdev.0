From: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 4 Dec 2008 20:05:22 +0100
Message-ID: <b98e548c0812041105o6c2ded8br3c2349cabceaf99f@mail.gmail.com>
References: <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
	 <Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
	 <20081204185022.6108d19e@gmail.com>
	 <20081204.101805.45306327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ldecicco@gmail.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:4312 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758928AbYLDTFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 14:05:34 -0500
Received: by gv-out-0910.google.com with SMTP id e6so866994gvc.37
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2008 11:05:32 -0800 (PST)
In-Reply-To: <20081204.101805.45306327.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dear david,

we have done many experiments, along with many other "researcher" as u
say. as a consequence, i have maturated the belief that changing the
probing phase of the van jacobson TCP, which is linear, could not be
not a wise thing .
 the rationale of  VJ choice seems simple to me: if  the window is
increased of one packet in one rtt, i can drop at most one packet in
one rtt and so i have to recover only one packet in one rtt (note that
rtt is the feedback reaction  time). If cwnd is increased of N packets
i could drop N packets and i could need to recover N pkts. this is the
problem here.

  window dynamics of  newreno cwnd behave  better, they are smoother.
others cwnd seem chaotic.
if you have   other experimental results showing the opposite, please
let me know.


thanks,
saverio

On Thu, Dec 4, 2008 at 7:18 PM, David Miller <davem@davemloft.net> wrote:
> From: Luca De Cicco <ldecicco@gmail.com>
> Date: Thu, 4 Dec 2008 18:50:22 +0100
>
>> Thank you for pointing out, we employed the kernel 2.6.24 with web100
>
> That is so ancient, especially TCP wise, it isn't even funny.
>
> And using the web100 patch adds yet more variables to the equation.
>
> It doesn't really reflect what users are actually running in the world
> today, not by a country mile.
>
> You're not comparing what we're actually shipping in the kernel.org
> kernel at all with your tests, which means your tests and results are
> something close to useless for us.
>
> I don't udnerstand why there are so many people who dice up their
> kernels, or use very old kernels, then do some "research" and then
> suggest we should change this or that with the kernel.org kernel as a
> result.
>
> Sorry, nobody here is going to take that seriously at all.
>



-- 
Prof. Saverio Mascolo
Dipartimento di Elettrotecnica ed Elettronica
Politecnico di Bari
Via Orabona 4
70125 Bari
Italy
Tel. +39 080 5963621
Fax. +39 080 5963410
email:mascolo@poliba.it

http://www-dee.poliba.it/dee-web/Personale/mascolo.html


=================================
 This message may contain confidential and/or legally privileged information.
  If you are not the intended recipient of the message, please destroy it.
 Any unauthorized dissemination, distribution, or copying of the material in
 this message, and any attachments to the message, is strictly forbidden.
