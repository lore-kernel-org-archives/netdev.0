From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH RFC 1/2] ipv6: add the IPV6_FL_F_REPLY flag to IPV6_FL_A_GET
Date: Thu, 12 Dec 2013 11:39:30 +0100
Message-ID: <52A99262.1090001@enst-bretagne.fr>
References: <1386844697-31169-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:37889 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380Ab3LLKjc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 05:39:32 -0500
Received: from reglisse.fourcot.fr (unknown [IPv6:2001:470:51a3:666::1])
	(Authenticated sender: reglisse)
	by olfflo.fourcot.fr (Postfix) with ESMTPSA id 777E52E034
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 11:39:31 +0100 (CET)
Received: from [IPv6:::1] (localhost [IPv6:::1])
	by reglisse.fourcot.fr (Postfix) with ESMTPS id 834A178F8FB
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 11:39:30 +0100 (CET)
In-Reply-To: <1386844697-31169-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There two patches extend the flow API. It adds three new actions with
IPV6_FLOWLABEL_MGR:

 * setsockopt with IPV6_FL_A_GET and IPV6_FL_F_REPLY set:
      enable the reply of flow label, packet are sent with the
      last low label read in packet sent by remote device
 * setsockopt with IPV6_FL_A_PUT and IPV6_FL_F_REPLY set:
      disable the flow label reply
 * getsockopt with IPV6_FL_A_GET and IPV6_FL_F_REPLY set:
      get the flow label send by the remote device


I'm not sure of the best way to do that. First, should we allocate a
real flow label in the global flow label? I don't think so, and it could
add hard issues with the system of permission/sharing.

Second, I was not sure of the best way for the coverage for all TCP states.

Regards,

Florent.
