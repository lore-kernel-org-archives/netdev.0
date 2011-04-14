From: Kristoff Bonne <kristoff.bonne@skypro.be>
Subject: ipv6 multicasting: "interface-local" scope
Date: Thu, 14 Apr 2011 19:23:07 +0200
Message-ID: <io7ahs$cpt$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46578 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192Ab1DNRZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 13:25:07 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QAQHy-000488-8D
	for netdev@vger.kernel.org; Thu, 14 Apr 2011 19:25:06 +0200
Received: from 91.181.176.68 ([91.181.176.68])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 19:25:06 +0200
Received: from kristoff.bonne by 91.181.176.68 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 19:25:06 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


(This is a repost of a message I posted yesterday in
linux.network.general but to which I have not seen any replies).


If I understand RFC 4291 correctly, the ipv6 multicast ip-addresses
ffx1:<scope> are "interface local" scope.

In draft-ietf-ipngwg-scoping-arch-02, I read this:
"The interface-local scope spans a single interface only; a multicast
address of interface-local scope is useful only for loopback delivery of
multicasts within a single node, for example, as a form of inter-process
communication within a computer".


This is exactly what I want to do for an application I am working on.

However when I try it and make a small program that sends out UDP
packats to the ipv6 multicast address ff11::1234, I do see them show up
on remote machines on my LAN!
So it looks like these packets do leave my local compute which -I think-
is the opposite of what RFC4291 tells me should happen.

Am I missing something? or is this a bug?



The machine on which I have tested this runs ubuntu 10.04.1 LTE with
kernel 2.6.32-30-generic



Anybody any ideas?



links:
- RFC4291: http://tools.ietf.org/html/rfc4291#section-2.7
- draft-ietf-ipngwg-scoping-arch-02:
http://tools.ietf.org/html/draft-ietf-ipngwg-scoping-arch-02)

Cheerio! Kr. Bonne.


