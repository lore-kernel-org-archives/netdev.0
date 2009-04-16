From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 16:01:16 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161555040.23632@qirst.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com> <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:34747 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbZDPUI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 16:08:28 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9DDE182C2F8
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 16:18:21 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ryzSZDmOhuet for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 16:18:17 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9823782C2F0
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 16:18:11 -0400 (EDT)
In-Reply-To: <49E78C1E.9060405@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Eric Dumazet wrote:

> Also you might check /proc/interrupts, because recent linux versions are
> distributing interrupts on all cpus instead of one on previous version

Argh. I just checked it and the systems used for the test had no irq
pinning. We are rerunning the series.

