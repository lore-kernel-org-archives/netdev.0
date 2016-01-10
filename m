From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Namespaceify tcp keepalive machinery
Date: Sun, 10 Jan 2016 17:32:36 -0500 (EST)
Message-ID: <20160110.173236.1276231217484676426.davem@davemloft.net>
References: <1452177525-13244-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, ebiederm@xmission.com, fan.du@intel.com,
	kaber@trash.net, jmorris@namei.org, alexander.h.duyck@redhat.com,
	kuznet@ms2.inr.ac.ru, operations@siteground.com
To: kernel@kyup.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757409AbcAJWck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 17:32:40 -0500
In-Reply-To: <1452177525-13244-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Borisov <kernel@kyup.com>
Date: Thu,  7 Jan 2016 16:38:42 +0200

> The following patch series enables the tcp keepalive mechanism
> to be configured per net namespace. This is especially useful
> if you have multiple containers hosted on one node and one of 
> them is under DoS-  in such situations one thing which could 
> be done is to configure the tcp keepalive settings such that 
> connections for that particular container are being reset 
> faster.
> 
> Another scenario where not being able to control those knob
> comes per container is problematic is occurs the value of 
> net.netfilter.nf_conntrack_tcp_timeout_established is set
> below the keepalive interval, in such situations the server won't 
> send an RST packet resulting in applications not trying to 
> reconnect and stale connection waiting. Changing the global 
> keepalive value is a possible solution but it might interfere
> with other containers. 
> 
> The three patches gradually convert each of the affected knobs
> to be per netns. I thought it would be easier for review than 
> put everything in one patch. If people deem it more appropriate 
> to squash everything in one patch (maybe after review) I'd
> be more than happy to do it. 
> 
> The patches have been compile-tested on 4.4 and functionally 
> tested on 3.12 and they work as expected. 
> 
> These are based off 4.4-rc8

Series applied, thanks.
