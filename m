From: Chuck Lever <chuck.lever@oracle.com>
Subject: IPv6: presentation format for zero scope ID
Date: Mon, 7 Dec 2009 16:45:03 -0500
Message-ID: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton@redhat.com>
To: Linux Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:24237 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964982AbZLGVpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 16:45:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I recently added some functions to sunrpc.ko that behave like  
getnameinfo(AI_NUMERICHOST) does in user space.

One of the functions, rpc_ntop6(), sticks a scope ID on the end of  
link- and site-local IPv6 addresses.  It does not try to map the scope  
ID to a device name.

It has been pointed out, however, that glibc's getnameinfo(3) skips  
appending a device name if the scope ID is zero.  Should rpc_ntop6()  
display or ignore zero scope IDs?  Would it be better if it also  
converted scope IDs to device names?

I'm not familiar enough with the IETF mandates regarding presentation  
address format, or the idiosyncrasies of the Linux IPv6  
implementation, to know what is the desired behavior here.  Any  
guidance appreciated.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
