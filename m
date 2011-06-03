From: Ben Greear <greearb@candelatech.com>
Subject: Are we allowed to add a new column to /proc/net/tcp?
Date: Fri, 03 Jun 2011 15:34:06 -0700
Message-ID: <4DE9615E.1010309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60785 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637Ab1FCWeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 18:34:07 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p53MY6cf025463
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 15:34:07 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd like to add mss so that we can calculate the window
size (which is cwnd * mss if I understand properly).

If there is another way to get at this information for
arbritrary TCP sockets, I'm interested in that as well.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

