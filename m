From: Mihamina Rakotomandimby <mihamina@gulfsat.mg>
Subject: tc download always to "default"
Date: Mon, 22 Mar 2010 13:44:39 +0300
Message-ID: <20100322134439.517b4447@pbmiha.malagasy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-104-36.blueline.mg ([41.204.104.36]:53823 "EHLO
	mail.blueline.mg" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754203Ab0CVLFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 07:05:12 -0400
Received: from localhost (spamassassin.malagasy.com [41.204.104.47])
	by mail.blueline.mg (Postfix) with ESMTP id 0B76FF821
	for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 13:44:47 +0300 (EAT)
Received: from mail.blueline.mg ([41.204.104.38])
	by localhost (spamassassin.malagasy.com [41.204.104.47]) (amavisd-new, port 10024)
	with ESMTP id A15ZtUI5I8ov for <netdev@vger.kernel.org>;
	Mon, 22 Mar 2010 13:50:32 +0300 (EAT)
Received: from pbmiha.malagasy.com (sysadmin-cnc.malagasy.com [41.204.104.9])
	by mail.blueline.mg (Postfix) with ESMTP id E053FF820
	for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 13:44:46 +0300 (EAT)
Received: from localhost ([127.0.0.1] helo=pbmiha.malagasy.com)
	by pbmiha.malagasy.com with esmtp (Exim 4.69)
	(envelope-from <mihamina@gulfsat.mg>)
	id 1Ntf7f-0001cl-Ln
	for netdev@vger.kernel.org; Mon, 22 Mar 2010 13:44:39 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Manao ahoana, Hello, Bonjour,

This is my simple topology:

  LAN <--> (eth1)[gateway](eth2) <--> Internet

The gataway NATs (Masquerade) but there is no trouble about this.

I would like to limit the DOWNLOAD bandwidth per host.
Download is:

  Internet -> gateway -> eth1 -> LAN Host

LAN is 10.150.0.128/25

There are sample lines of my "tc" ruleset: 
http://pastebin.org/119806


My problem is all the traffic is caught by "classid 1:10", the default
class.

Nothing is trapped by "classid 1:301" -> "classid 1:426"

At a first glance, would you see something wrong in these?

Misaotra, Thanks, Merci.

-- 
       Architecte Informatique chez Blueline/Gulfsat:
    Administration Systeme, Recherche & Developpement
                +261 34 29 155 34 / +261 33 11 207 36
