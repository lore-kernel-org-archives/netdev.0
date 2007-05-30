From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 12:18:18 +0100
Message-ID: <465D5D7A.8090200@andyfurniss.entadsl.com>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:48385 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751506AbXE3LSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 07:18:05 -0400
In-Reply-To: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> One good thing about ESFQ is the more flexible flow classification, but
> I don't like the concept of having a set of selectable hash functions
> very much.
> 
> These patches change SFQ to allow attaching external classifiers and add
> a new "flow" classifier that allows to classify flows based on an arbitary
> combination of pre-defined keys. Its probably not the fastest classifier
> when used with multiple keys, but frankly, I don't think speed is very
> important in most situations where the current SFQ implementation is used.
> 
> It currently does not support perturbation, I didn't want to move this into
> the classifier, so I need to think about a way to handle it within SFQ.
>

Cool, but isn't this going to show the same collision problems that the
pre jhash esfq saw?

Andy.
