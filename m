From: jamal <hadi@cyberus.ca>
Subject: Re: Oops in filter add
Date: Wed, 21 Mar 2007 05:33:44 -0400
Message-ID: <1174469624.16343.2.camel@localhost>
References: <45FEEE35.6090606@reflexsecurity.com>
	 <20070319.192206.21926062.davem@davemloft.net>
	 <1174373645.4895.15.camel@localhost>  <45FF8602.8040108@trash.net>
	 <1174375109.4895.22.camel@localhost>  <45FF8D6A.4010308@trash.net>
	 <1174382739.4864.11.camel@localhost>  <45FFBE5A.1020807@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chris@reflexsecurity.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:54680 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbXCUJrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 05:47:42 -0400
Received: by py-out-1112.google.com with SMTP id a29so67282pyi
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2007 02:47:42 -0700 (PDT)
In-Reply-To: <45FFBE5A.1020807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-20-03 at 11:58 +0100, Patrick McHardy wrote:
> jamal wrote:

> > So the resolution (as Dave points out) was wrong. In any case, restoring
> > queue_lock for now would slow things but will remove the race.
> 
> 
> Yes. I think thats what we should do for 2.6.21, since fixing
> this while keeping ingress_lock is quite intrusive.
> 

reasonable.

> I'm on it. I'm using the opportunity to try to simply the qdisc locking.

Ok, thanks Patrick. 
BTW, I was just staring at the code and i think i have found probably a
long standing minor bug on the holding of the tree lock. I will post
 a patch shortly if i dont get disrupted.

cheers,
jamal

