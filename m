From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] sctp: lock_sock_nested in sctp_sock_migrate
Date: Mon, 25 Jun 2007 13:24:00 -0700
Message-ID: <46802460.3080303@linux.intel.com>
References: <20070622221446.GB7547@mami.zabbo.net> <46802477.5030005@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zach Brown <zach.brown@oracle.com>,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3786 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbXFYUZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 16:25:44 -0400
In-Reply-To: <46802477.5030005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote:
> Hm... This is another case of of two different sockets taking the same lock...
> 
> Arjan,  did this every get fixed, or is the nested locking the right solution
> to this?
> 

for this specific case it's ok and the nested solution is right.
In the general case it's obviously not safe to take the locks of two 
sockets in "unspecified" order....
