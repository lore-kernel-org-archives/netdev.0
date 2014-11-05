From: James Yonan <james@openvpn.net>
Subject: Can ndo_select_queue save data in skb->cb?
Date: Wed, 05 Nov 2014 10:57:00 -0700
Message-ID: <545A64EC.309@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.yonan.net ([54.244.116.145]:47330 "EHLO mail.yonan.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035AbaKESEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 13:04:34 -0500
Received: from Moab.local (c-67-166-32-18.hsd1.co.comcast.net [67.166.32.18])
	(using TLSv1 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail.yonan.net (Postfix) with ESMTPSA id 3DE3DC0E5D
	for <netdev@vger.kernel.org>; Wed,  5 Nov 2014 10:57:01 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it permissible for a net driver's ndo_select_queue method to save 
data in skb->cb for later use in ndo_start_xmit?

Also, is it necessary for users of skb->cb to zero out their private 
data after use to prevent it from being misinterpreted by other layers? 
  I noticed some commits in the log (such as 462fb2) are zeroing out the 
skb->cb area for this reason.

Thanks,
James
