From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 17:32:08 +0200
Message-ID: <465D98F8.9000102@trash.net>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain> <465D5D7A.8090200@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: lists@andyfurniss.entadsl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42085 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbXE3PcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 11:32:11 -0400
In-Reply-To: <465D5D7A.8090200@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Furniss wrote:
> Patrick McHardy wrote:
> 
>> It currently does not support perturbation, I didn't want to move this
>> into
>> the classifier, so I need to think about a way to handle it within SFQ.
>>
> 
> Cool, but isn't this going to show the same collision problems that the
> pre jhash esfq saw?


Perturbation doesn't prevent collisions, it just distributes them
(hopefully evenly). My classifier uses jhash, but that won't prevent
collisions either. Anyways, I'm going to change SFQ so perturbation
can also be used with external classifiers.
