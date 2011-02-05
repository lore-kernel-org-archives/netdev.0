From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-2.6 PATCH 2/3] net: dcb: use _safe() version of list iterators
Date: Sat, 05 Feb 2011 11:40:35 -0800
Message-ID: <4D4DA7B3.4030208@intel.com>
References: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>	<20110131220054.29758.20521.stgit@jf-dev1-dcblab> <20110131.204214.71133534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5589 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753688Ab1BETkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Feb 2011 14:40:36 -0500
In-Reply-To: <20110131.204214.71133534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2011 8:42 PM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Mon, 31 Jan 2011 14:00:54 -0800
> 
>> Use _safe() version of list iterator macros in dcb_setapp().
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Why?  It's unnecessary overhead, since we always branch to "out", and
> therefore out of the list traversal loop, any time we list_del()
> something on the list.

Of course you are right there is no reason for this. Thanks.
