From: David Howells <dhowells@redhat.com>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 14:24:49 +0100
Message-ID: <7884.1178285089@redhat.com>
References: <20070504131657.GA2291@2ka.mipt.ru>  <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35583 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156AbXEDNY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:24:58 -0400
In-Reply-To: <20070504131657.GA2291@2ka.mipt.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> > Should route_get_raw() release the rtable if gets back?
> 
> Yes, dst entry should be released when not used anymore.

I meant the rtable returned by __ip_route_output_key(), not the dst.

David
