From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET_SCHED]: cls_fw: fix NULL pointer dereference
Date: Wed, 6 Dec 2006 14:18:07 +0100
Message-ID: <20061206131807.GA2858@ff.dom.local>
References: <45744016.8080707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:48834 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760587AbWLFNLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 08:11:15 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45744016.8080707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04-12-2006 16:34, Patrick McHardy wrote:
> Fix a regression from my nfmark mask patch for cls_fw.
> 
> Thomas, Jamal, do you have an idea what this "old method" stuff
> is used for? It seems it is only used during the below mentioned
> race.
> 

Sorry for eavesdropping, but have a look at htb_classify
starting comment. It is also used by unofficial but quite
popular IPMARK target. 

Jarek P.
