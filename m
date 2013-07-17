From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: add necessary locking on device removal
Date: Wed, 17 Jul 2013 12:51:42 -0700 (PDT)
Message-ID: <20130717.125142.1546753660233139444.davem@davemloft.net>
References: <20130710155840.73e8da09@nehalam.linuxnetplumber.net>
	<CALnjE+rO7Npw=rU_VL7T1pPDdFBKXB3KpVbpf_jQ0cJ6+ah1nQ@mail.gmail.com>
	<20130713101818.0d4fa8e0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540Ab3GQTv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 15:51:57 -0400
In-Reply-To: <20130713101818.0d4fa8e0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 13 Jul 2013 10:18:18 -0700

> The socket management is now done in workqueue (outside of RTNL)
> and protected by vn->sock_lock. There were two possible bugs, first
> the vxlan device was removed from the VNI hash table per socket without
> holding lock. And there was a race when device is created and the workqueue
> could run after deletion.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
