From: Luciano Ruete <lruete@sequre.com.ar>
Subject: Netfilter MARK on tc ingress and ifb redirect
Date: Wed, 3 Nov 2010 17:25:55 -0300
Message-ID: <201011031725.55722.lruete@sequre.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.vita.com.ar ([190.15.193.98]:43555 "HELO vita.com.ar"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753563Ab0KCUci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 16:32:38 -0400
Received: from lakshmi.localnet (host.190.15.203.70.static.itcsa.net [190.15.203.70])
    (authenticated-user luciano@praga.org.ar)
    by mail.vita.com.ar with SMTP id zct7cqg2n4dswcctgxzm53a6ae;
    for netdev@vger.kernel.org;
    Wed, 03 Nov 2010 17:25:54 -0300 (ART)
    (envelope-from lruete@sequre.com.ar)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Im developing a FLOSS ISP solution based on iptables/tc/iproute2

2 stumbling blocks that I found in my path

1) It would be very usefull have this working

tc filter add dev eth0 parent :ffff ... action ipt -j CONNMARK --restore-mark

where :ffff is an ingress qdisc, i know that currently this is not working nor 
coded.
Is this anyhow in the sight or TODO list of the iproute2 developers to have 
connmark available in ingress?

If not, how complex will be to implement it? (ie: lines of code number)

2) For a technical reason we need to be able to do:

tc filter action mirred egress redirect dev ifbx

at least twice in the same qdisc tree or nested in the redirected ifb, now 
only the first filter matched returns. That was possible in (i think) pre 2.6.18 
kernels but changed to avoid an infinite loop.

Is there any chance to have that behavior back using a kernel flag or 
something? 

PD: Plz CC me i'm not suscribed (I try but never get the reply)

-- 
Luciano Ruete
Sequre - Sys Admin
Mitre 617, piso 7, of. 1 
+54 261 4254894
Mendoza - Argentina
http://www.sequre.com.ar/
