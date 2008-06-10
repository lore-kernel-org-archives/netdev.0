From: Chase Douglas <chasedouglas@gmail.com>
Subject: ping6 ff02::1 on eth0 shows echo reply on lo
Date: Tue, 10 Jun 2008 15:32:34 -0400
Message-ID: <59F16AFE-888B-484E-B04A-CBFDA318ED17@gmail.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:65316 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbYFJTdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:33:06 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1729118ywe.1
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2008 12:32:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing some testing, I've found that a ping request sent only on  
eth0 to link-local addresses (ping6 -I eth0 ff02::1) is causing lo to  
generate echo replies. Is this intended behavior or a bug somewhere?

Thanks
