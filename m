From: Patrick McHardy <kaber@trash.net>
Subject: Re: net-sched 00/06: dynamically sized class hashes v2
Date: Thu, 03 Jul 2008 18:49:27 +0200
Message-ID: <486D0317.8020008@trash.net>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain> <20080703161403.GA2637@ami.dom.local> <486CF9BC.9090202@trash.net> <20080703164601.GB2637@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42470 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600AbYGCQt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 12:49:29 -0400
In-Reply-To: <20080703164601.GB2637@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> BTW, BTW: I've just started to understand this "common" idea (I hope).
> So if it's planned for some other (not searching) fields common for
> classes, then of course, this name is quite sensible (maybe only a bit
> too long for dereferencing).
>   

Yes, child qdiscs, filter lists etc. would be a good start. I think we
should actually have at least two types of common structs, one for
hierarchical qdiscs, one for pseudo-classful like TBF, RED and netem.

I have some patches but they're a big mess so I seperated out the useful
stuff for now :)

