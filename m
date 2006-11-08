From: Ismail Donmez <ismail@pardus.org.tr>
Subject: HTB warnings
Date: Thu, 9 Nov 2006 00:16:41 +0200
Message-ID: <200611090016.41479.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:39578 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S1161745AbWKHWRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 17:17:12 -0500
Received: from vaio.local (unknown [85.101.41.16])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by uludag.org.tr (Postfix) with ESMTP id D52022E2E4DE
	for <netdev@vger.kernel.org>; Thu,  9 Nov 2006 00:17:06 +0200 (EET)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I use sabishape[1] to shape my traffic that I would normally do,

sabishape -i eth1 -u 40 -d 240 for my 256/64 ADSL line , but recently in dmesg 
I got following warnings:

HTB: quantum of class 10031 is small. Consider r2q change.
HTB: quantum of class 10032 is small. Consider r2q change.
HTB: quantum of class 10033 is small. Consider r2q change.

I thought sabishape might be buggy but wondershaper from LARTC gives the same 
warnings. So I wonder if anyone have any ideas?

[1]  http://sabi.co.uk/Proj/Small/sabishape-2.1.tar.gz


Regards,
ismail
