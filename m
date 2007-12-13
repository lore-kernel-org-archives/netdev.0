From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH 2.6.25] IPv4: thresholds in fib_trie.c are not modified,
 make them const
Date: Thu, 13 Dec 2007 10:32:58 +0300
Message-ID: <4760E02A.70509@sw.ru>
References: <20071212110555.GA11638@iris.sw.ru> <20071212.105833.237798467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, containers@lists.osdl.org, devel@openvz.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:51621 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752210AbXLMHbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 02:31:36 -0500
In-Reply-To: <20071212.105833.237798467.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Wed, 12 Dec 2007 14:05:55 +0300
> 
>> -static int halve_threshold = 25;
>> -static int inflate_threshold = 50;
>> -static int halve_threshold_root = 15;
>> -static int inflate_threshold_root = 25;
> 
> halve_threshold_root and inflate_threshold_root have different
> values in the net-2.6.25 tree.

oops. this was accidentally changed during porting of the code from the
one old tree and committed by mistake. I'll resend correct patch in a minute

> 
> What tree are you patching against?  These were changed way
> back in:
