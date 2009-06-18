From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] skbuff: skb_mac_header_was_set is always true on >32 bit
Date: Wed, 17 Jun 2009 18:53:01 -0700 (PDT)
Message-ID: <20090617.185301.172272524.davem@davemloft.net>
References: <20090617082327.196eda07@nehalam>
	<20090617163716.GA21530@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51071
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751296AbZFRBw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:52:57 -0400
In-Reply-To: <20090617163716.GA21530@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 17 Jun 2009 13:37:16 -0300

> Em Wed, Jun 17, 2009 at 08:23:27AM -0700, Stephen Hemminger escreveu:
>> Looking at the crash in log_martians(), one suspect is that the check for
>> mac header being set is not correct.  The value of mac_header defaults to
>> 0 on allocation, therefore skb_mac_header_was_set will always be true on
>> platforms using NET_SKBUFF_USES_OFFSET.
>> 
>> Arnaldo, is this correct?
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Yeah, looks right, I forgot to initialize it to the value I changed the
> test in skb_mac_header_was_set when doing the offset patch :-\
> 
> Thanks!
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
