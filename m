From: Stephen Hemminger <shemminger@dslnorthwest.net>
Subject: Crash in ip_conntrack on shutdown
Date: Wed, 01 Nov 2006 16:56:35 -0800
Message-ID: <45494243.20001@dslnorthwest.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15761 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752380AbWKBA4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 19:56:38 -0500
Received: from [192.168.0.110] (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id kA20uZPn019980
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 1 Nov 2006 16:56:36 -0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My desktop machine (Fedora Core 6) crashed on during shutdown when 
running latest
2.6.19-rc4 kernel. Machine is UP Amd64.

It looks like a null dereference in ip_conntrack. See screenshot.
  
http://picasaweb.google.com/stephen.hemminger/LinuxCrashes/photo#4992593950061821970
