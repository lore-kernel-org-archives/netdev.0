From: Stefano Salsano <stefano.salsano@uniroma2.it>
Subject: Re: [RFC] netem: correlated loss generation (v3)
Date: Thu, 20 May 2010 00:52:00 +0200
Message-ID: <4BF46B90.1000806@uniroma2.it>
References: <4BD84428.30904@uniroma2.it> <20100517205621.036a06e0@nehalam> <20100519214239.GD5146@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Fabio Ludovici <fabio.ludovici@yahoo.it>,
	netdev@vger.kernel.org, netem@lists.linuxfoundation.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.uniroma2.it ([160.80.6.16]:54783 "EHLO smtp.uniroma2.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881Ab0ESXMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 19:12:09 -0400
In-Reply-To: <20100519214239.GD5146@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer wrote:
> * Stephen Hemminger | 2010-05-17 20:56:21 [-0700]:
> 
> Why mainline? I questioning the advantage for the big audience, it looks like
> a academic only piece of software - correct me if I'm wrong.
>

as an author, I can only give a "biased" point of view... anyway our 
work started from a cooperation with an industry which needed to test 
its solutions for fax/modem over IP under correlated loss.  When we put 
our first version on the netem list, we were asked by people from 
another industry to add the feature of loss patterns coming out from a 
deterministic table.

So my opinion is that the need to emulate "correlated" loss patterns is 
not academic, but it is a real need from industry... of course we can 
debate if it is a "niche" requirement or not

> The authors pointed to some weak points in the implementation of the current
> loss/correlation logic. But this "fix", add another - complicated component -
> and let the broken components untouched ...

Leaving or removing the broken component is an independent issue.

May be we should allow to use the old syntax like this:

tc qdisc change dev wlan0 root netem loss 2

because it was working OK, and we should disallow to use the old model 
in this way:

tc qdisc change dev wlan0 root netem loss 2 10

because this produces broken results...

BR,
Stefano

> 
> HGN
> 


-- 
*******************************************************************
Stefano Salsano
Dipartimento Ingegneria Elettronica
Universita' di Roma "Tor Vergata"
Via del Politecnico, 1 - 00133 Roma - ITALY

http://netgroup.uniroma2.it/Stefano_Salsano/

E-mail  : stefano.salsano@uniroma2.it
Cell.   : +39 320 4307310
Office  : (Tel.) +39 06 72597770  (Fax.) +39 06 72597435
*******************************************************************
