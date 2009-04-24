From: Christoph Lameter <cl@linux.com>
Subject: Re: about latencies
Date: Fri, 24 Apr 2009 10:00:17 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904240958070.20479@qirst.com>
References: <49F0E579.5030200@cosmosbay.com> <alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com> <49F0F49A.1050609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:55225 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbZDXOI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 10:08:58 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 810D682C22D
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 10:19:35 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9yqQ5GUA8lXb for <netdev@vger.kernel.org>;
	Fri, 24 Apr 2009 10:19:35 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CDA1982C239
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 10:19:30 -0400 (EDT)
In-Reply-To: <49F0F49A.1050609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Apr 2009, Eric Dumazet wrote:

> > you're running a latency sensitive test on a NOHZ kernel below, isn't that
> > a bad idea?
>
> I tried worst case to match (eventually) Christoph data.
> I usually am not using NOHZ, but what about linux distros ?

Why does NOHZ have an impact here? Timed wakeups can happen using
high res timers after all and a timer interrupt should be generated if the
network layer needs it.

