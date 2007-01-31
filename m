From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_prio: class statistics printing enabled
Date: Wed, 31 Jan 2007 16:23:04 +0100
Message-ID: <45C0B458.1090703@trash.net>
References: <20070131075348.GA1857@ff.dom.local> <45C09E0B.6020107@trash.net> <20070131143522.GB3521@ff.dom.local> <45C0A9A5.4080607@trash.net> <20070131150102.GA3643@ff.dom.local> <45C0B05D.3020101@trash.net> <20070131151721.GA3811@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64606 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030202AbXAaPXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 10:23:07 -0500
In-Reply-To: <20070131151721.GA3811@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Wed, Jan 31, 2007 at 04:06:05PM +0100, Patrick McHardy wrote:
> 
>>The class passed to both ->dump and ->dump_stats is not a classid but
>>a qdisc-internal identifier (pointer, integer, whatever) which comes
>>from either ->get or ->walk, and thus is valid unless these functions
>>have bugs. Your check would cover the bug up and has no other purpose.
> 
> 
> Maybe I miss something, but it's not "my check".

I don't care.

> I tried only to "stay in line with the remaining file"...

Keeping in line may make sense in case of coding style, but its
no replacement for understanding the code you're copying around.
The same check in prio_get is correct and necessary, while in
the function you add it is incorrect and covers up potential bugs.

So please remove it so we can stop this pointless discussion.
