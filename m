From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: [NETLINK] periodically rehash table, why?
Date: Wed, 14 Mar 2007 18:30:31 +0100
Message-ID: <877itju408.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:64278 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbXCNRaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 13:30:46 -0400
Received: from holger by kruemel.my-eitzenberger.de with local (Exim 4.50)
	id 1HRXJ1-00040J-HF
	for netdev@vger.kernel.org; Wed, 14 Mar 2007 18:30:31 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

in nl_pid_hash_dilute() there is:

   if (unlikely(avg > 1) && nl_pid_hash_rehash(hash, 1))
      return 1;

      if (unlikely(len > avg) && time_after(jiffies, hash->rehash_time)) {
         nl_pid_hash_rehash(hash, 0);
         return 1;
      }

I don't see a reason why periodically rehashing might help in any way
(without resizing).  Is there a reason for that?

Thanks.  /holger
      



