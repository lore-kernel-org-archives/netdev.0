From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 15:06:59 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161504090.15835@qirst.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com> <49E76906.2060205@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:34876 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757320AbZDPTOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:14:16 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 007C282C2EA
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 15:24:10 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Lgr-rSOe4fMy for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 15:23:52 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 35EE182C2CA
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 15:23:52 -0400 (EDT)
In-Reply-To: <49E76906.2060205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Rick Jones wrote:

> Does udpping have a concept of service demand a la netperf?  That could help
> show how much was code bloat vs say some tweak to interrupt coalescing
> parameters in the NIC/driver.

No. What does service on demand mean? The ping pong tests are very simple
back and forths without any streaming or overlay.
