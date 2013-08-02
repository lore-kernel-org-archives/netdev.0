From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [Patch net-next 1/2] net: fix a compile error when CONFIG_NET_LL_RX_POLL
 is not set
Date: Fri, 02 Aug 2013 06:04:11 +0300
Message-ID: <51FB21AB.6090003@linux.intel.com>
References: <1375326625-21427-1-git-send-email-amwang@redhat.com> <51FA060A.2060202@linux.intel.com> <1375344487.7780.14.camel@cr0> <20130801.130338.1147816900371465134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6043 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753829Ab3HBDEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 23:04:14 -0400
In-Reply-To: <20130801.130338.1147816900371465134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2013 23:03, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Thu, 01 Aug 2013 16:08:07 +0800
> 
>> Thinking about it again, what is the point of your commit commit
>> 89bf1b5a683df497c572c4d3bd3f9c9aa919d773 (net: remove NET_LL_RX_POLL
>> config menue)? After that commit, CONFIG_NET_LL_RX_POLL is not visible
>> by user and no other configs select it, also since it defaults to y, it
>> will be _always_ enabled. If this is really what you want, we can simply
>> remove all !CONFIG_NET_LL_RX_POLL code.
> 
> Yes we could do that, it has no dependencies which is the usual reason
> to have a hidden Kconfig var like this.

I think we still need a config option that depends on net and the
placeholder code.
What happens then if someone does not configure networking?
Won't this break select and poll?
