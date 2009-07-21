From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Constantly varying download rate with a complex xen networking
 setup, why?
Date: Tue, 21 Jul 2009 11:52:28 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0907211143100.10534@wel-95.cs.helsinki.fi>
References: <20090615075313.GA22819@rivendell> <Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI> <20090615160254.GA8550@rivendell> <Pine.LNX.4.64.0906151910220.16408@melkinkari.cs.Helsinki.FI> <20090617130050.GA18586@rivendell>
 <Pine.LNX.4.64.0906171659380.31880@melkinkari.cs.Helsinki.FI> <20090617143647.GD18586@rivendell>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1468014785-1248165953=:10534"
Cc: Netdev <netdev@vger.kernel.org>
To: Raphael Hertzog <raphael@ouaza.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42888 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbZGUIw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 04:52:29 -0400
In-Reply-To: <20090617143647.GD18586@rivendell>
Content-ID: <alpine.DEB.2.00.0907211149160.10534@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1468014785-1248165953=:10534
Content-Type: TEXT/PLAIN; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0907211149161.10534@wel-95.cs.helsinki.fi>

On Wed, 17 Jun 2009, Raphael Hertzog wrote:

> Le mercredi 17 juin 2009, Ilpo Järvinen a écrit :
>> On Wed, 17 Jun 2009, Raphael Hertzog wrote:
>>
>>> Le lundi 15 juin 2009, Ilpo Järvinen a écrit :
>>>> Maybe the proxy interferes there somehow... I don't know enough about the
>>>> details to say but I suppose the proxy at least breaks your tcp connection
>>>> to two parts.
>>>
>>> Indeed. Is there some processing done in a simple linux bridge where the
>>> reapperance of the same TCP packet that has been created and sent on another
>>> local interface could create problem?
>>
>> I thought out had a http proxy in between? I suppose it is certainly doing
>> more than bridging. Anyway, I'll be week away, so no quick responses are
>> to be expected from my part after this mail.
>
> Well, I have the problem when I don't use the proxy... if I use it, the
> download is split over two TCP connections and things are fine.
>
> Hence my question was if something could be confused by the fact that the
> same packet is seen twice on the same machine once (in output) via 
> eth2/xenbrD and once (in forward) via xenbrE (the routing between both 
> bridges is done by the domU independently of the dom0 network config).

Did you ever get tcpdumps btw? Looking into your setup it would probably 
be useful take it from all the interfaces where the packets are supposed 
to pass.


-- 
  i.
--8323329-1468014785-1248165953=:10534--
