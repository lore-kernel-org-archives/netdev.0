From: Rick Jones <rick.jones2@hp.com>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds
 want to know why its set to zero)
Date: Wed, 16 Jul 2008 13:39:37 -0700
Message-ID: <487E5C89.7050005@hp.com>
References: <OF4F3F2DB0.24836443-ON88257488.0068C9C1-88257488.0068F7AD@us.ibm.com>	<487E4A6B.6040103@linux-foundation.org> <20080716.133048.201600858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:35230 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbYGPUjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 16:39:41 -0400
In-Reply-To: <20080716.133048.201600858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have vague recollections of wanting to avoid (then) locks on the 
increment in the non-fragmented paths, assertions that covering cases 
like intermediate devices ignoring DF and fragmenting anyway didn't 
warrant concern etc.

rick jones
