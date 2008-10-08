From: Krzysztof Oledzki <ole@ans.pl>
Subject: Error: an inet prefix is expected rather than "0/0".
Date: Wed, 8 Oct 2008 23:05:12 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0810082258240.13921@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-1726530140-1223499912=:13921"
Cc: shemminger@vyatta.com
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:55118 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbYJHVFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 17:05:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-1726530140-1223499912=:13921
Content-Type: TEXT/PLAIN; format=flowed; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT

Hello,

It seems that never versions of iproute (tested with iproute2-2.6.26) no 
longer allow 0/0:

# ip route add 0/0 via 192.168.0.1
Error: an inet prefix is expected rather than "0/0".

Is it intentional? It breaks startup scripts.

Best regards,

 			Krzysztof Olêdzki
---1144830174-1726530140-1223499912=:13921--
