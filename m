From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: Established connections hash function
Date: Wed, 28 Mar 2007 11:29:43 +0200
Message-ID: <200703281129.43783.ak@suse.de>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <p73lkhi6aj7.fsf@bingen.suse.de> <EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nikb@webmaster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34957 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbXC1J3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 05:29:51 -0400
In-Reply-To: <EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> > But I think it can be mostly ignored.
> 
>     With all due respect, it cannot. An attacker with a small-sized botnet 
> (which is ~250 hosts) can create chains that contain well in excess of 3000 
> items. 

Most likely they can also easily generate enough latency data to crack any simple
hash function then.

-Andi
