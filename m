From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next] bridge: Add bridge port learn filter and
 priority
Date: Wed, 18 Jun 2014 13:34:05 -0700
Message-ID: <20140618133405.515b3741@nehalam.linuxnetplumber.net>
References: <1403075767-31908-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, scotte@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, shm@cumulusnetworks.com,
	nolan@cumulusnetworks.com, sfeldma@cumulusnetworks.com,
	jhs@mojatatu.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58308 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbaFRUeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 16:34:10 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so1048394pdi.4
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 13:34:09 -0700 (PDT)
In-Reply-To: <1403075767-31908-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jun 2014 00:16:07 -0700
roopa@cumulusnetworks.com wrote:

> One such topology is when there are multiple paths to a dual-homed host.

That is called a loop.
Loops are not allowed on bridge networks.
Sorry, this is just the kind of things spanning tree and TRILL were supposed
to address. Solving in local bridge is not a good idea.
