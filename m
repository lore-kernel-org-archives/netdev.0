From: Patrick McHardy <kaber@trash.net>
Subject: Re: can SFQ and perturb break paquet ordering ?
Date: Wed, 10 Mar 2010 13:30:10 +0100
Message-ID: <4B9790D2.7030005@trash.net>
References: <ca4f1a12b3ba9c81f3276c091063613f@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julien Vehent <julien@linuxwall.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56536 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab0CJMaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 07:30:11 -0500
In-Reply-To: <ca4f1a12b3ba9c81f3276c091063613f@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julien Vehent wrote:
> Hi netdev folks,
> 
> I was digging into the sch_sfq code and I was wondering the following (I
> assume it's nothing new, I'm just trying to get it right):
> 
> Let's consider one UDP connection that has two packets. Packet#1 goes to
> bucket#1, then perturb modifies the hashing algorithms and thus Packet#2
> goes to bucket#800.
> 
> If the round robin was positionned after bucket#1 but before bucket#800
> when perturb occured, then Packet#2 will be sent before Packet#1. And since
> UDP can't reordered, it will be processed before on the received end.
> 
> Am I getting this right or is there something in the code that I missed ?

That's correct.
