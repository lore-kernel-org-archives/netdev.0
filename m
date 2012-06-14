From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 0/8] dcbnl: Major simplifications
Date: Thu, 14 Jun 2012 09:06:20 -0700
Message-ID: <4FDA0BFC.90807@intel.com>
References: <cover.1339591572.git.tgraf@suug.ch> <20120613.155541.26513304496438357.davem@davemloft.net> <20120614075435.GA29185@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lucy.liu@intel.com
To: tgraf@suug.ch, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61658 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754256Ab2FNQGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 12:06:50 -0400
In-Reply-To: <20120614075435.GA29185@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/14/2012 12:54 AM, Thomas Graf wrote:
> On Wed, Jun 13, 2012 at 03:55:41PM -0700, David Miller wrote:
>> Lots of deleted code, I like it :-)
>>
>> Applied, but could you send a follow-on patch to use BUG_ON() instead
>> of that "if (!ptr) { /* ... */ BUG(); }" construct?
>
> Sure, I must have had a weak moment right there :)
>

Nice! I'm a bit late but dumped this into my dcbnl netlink test kit
and everything looks good so...

Tested-by: john.r.fastabend@intel.com
