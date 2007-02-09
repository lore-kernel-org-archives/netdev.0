From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: Fri, 9 Feb 2007 11:10:33 +0100
Message-ID: <200702091110.34125.ak@suse.de>
References: <200702091006.24242.dada1@cosmosbay.com> <200702091036.58474.dada1@cosmosbay.com> <20070209.014344.63999119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, linux@horizon.com, akepner@sgi.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:45218 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946265AbXBIKKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 05:10:38 -0500
In-Reply-To: <20070209.014344.63999119.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 10:43, David Miller wrote:

> Current gcc does the right thing, even for weird sizes like 56 and 52
> which expands to many IALU operations.

... except if you use -Os, which at least on x86* is default and is what
distros ship with.

-Andi

