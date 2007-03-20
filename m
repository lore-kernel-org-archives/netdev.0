From: jamal <hadi@cyberus.ca>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 03:18:29 -0400
Message-ID: <1174375109.4895.22.camel@localhost>
References: <45FEEE35.6090606@reflexsecurity.com>
	 <20070319.192206.21926062.davem@davemloft.net>
	 <1174373645.4895.15.camel@localhost>  <45FF8602.8040108@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chris@reflexsecurity.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:22992 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbXCTHSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 03:18:34 -0400
Received: by an-out-0708.google.com with SMTP id b33so1673371ana
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 00:18:33 -0700 (PDT)
In-Reply-To: <45FF8602.8040108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-20-03 at 07:58 +0100, Patrick McHardy wrote:
> jamal wrote:

> > The main idea is to avoid one BigLock for both ingress and egress;
> > Which was/is still useful in the compat mode where netfilter is used
> > instead. 
> 
> 
> In that case is isn't even used.
> 

Ok. It certainly used to matter in the old days.

> You would need to make qdisc_lock_tree() aware of the difference
> between ingress and egress.

If you have the cycles please go ahead - I really dont have much time
today (have to present in a few hours and havent even started).
I will most certainly look in 1-2 days; for now the queue_lock should
suffice; 


cheers,
jamal

