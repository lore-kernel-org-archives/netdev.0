From: Andi Kleen <ak@suse.de>
Subject: Re: hard hang through qdisc II
Date: Thu, 31 Jan 2008 13:43:13 +0100
Message-ID: <200801311343.13669.ak@suse.de>
References: <200801311321.01015.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:54944 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759285AbYAaMnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 07:43:17 -0500
Received: from Relay1.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 855202784A
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 13:43:16 +0100 (CET)
In-Reply-To: <200801311321.01015.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 31 January 2008 13:21:00 Andi Kleen wrote:
> 
> I just managed to hang a 2.6.24 (+ some non network patches) kernel 
> with the following (non sensical) command

Correction: the kernel was actually a git linus kernel with David's 
recent merge included.

I found it's pretty easy to hang the kernel with various tbf parameters.

-Andi

> tc qdisc add dev eth0 root tbf rate 1000 burst 10 limit 100
> 
> No oops or anything just hangs. While I understand root can
> do bad things just hanging like this seems a little extreme.
> 
> -Andi
> 


