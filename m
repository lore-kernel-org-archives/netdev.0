From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: LRO restructuring?
Date: Wed, 18 Feb 2009 11:46:55 -0800
Message-ID: <20090218114655.46538a82@extreme>
References: <20080811.175434.215224347.davem@davemloft.net>
	<20080812010004.GD18547@gondor.apana.org.au>
	<48A0E7A3.6030200@hp.com>
	<20080811.183913.09225669.davem@davemloft.net>
	<20080812015321.GA19011@gondor.apana.org.au>
	<loom.20090218T192451-89@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Huang <jamesclhuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42812 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505AbZBRTq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 14:46:57 -0500
In-Reply-To: <loom.20090218T192451-89@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Feb 2009 19:25:49 +0000 (UTC)
James Huang <jamesclhuang@gmail.com> wrote:

> Hi Herbert,
> 
>     Any idea when this LRO restructuring work will be done? 
> Making LRO available even when ip forwarding is enabled will significantly 
> improve performace of network appliances in the data path.  

LRO with ip forwarding is a bad idea since it violates the end-to-end
principle. It might even be a DO NOT in host requirements RFC.
