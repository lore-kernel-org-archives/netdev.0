From: Fernando Gont <fernando@gont.com.ar>
Subject: Question about reading the routing table with netlink
Date: Tue, 10 Sep 2013 11:21:44 -0300
Message-ID: <522F2AF8.9080106@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:45085 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832Ab3IJOVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 10:21:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

Short version of the question:
I'm trying to loop up a routing table entry with a
socket(AF_NETLINK,SOCK_RAW,NETLINK_ROUTE).

Everything seems fine, except that I do not quite understand what's the
effect of setting the RTA_SRC attribute type when doing that.

Empirically, it seems that if the RTA_SRC attribute is set and it
contains an address that is assigned to the interface involved in the
route, then such address is later returned in the reply as an RTA_SRC
attribute.


Aside question, I was curious about the NETLINK_FIB_LOOKUP family (I
guess it can be used for the same purpose?) -- but I wasn't able to get
much information about it.

Any help will be welcome.

Thanks!

P.S.: Not sure if this is the right forum to ask this.. please direct me
elsewhere if appropriate.

Best regards,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
