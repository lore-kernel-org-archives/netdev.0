From: Rick Jones <rick.jones2@hp.com>
Subject: Re: IP address: property of host or interface?
Date: Mon, 26 Jan 2009 09:43:05 -0800
Message-ID: <497DF629.70602@hp.com>
References: <497B1E5E.9050309@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:6582 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584AbZAZRnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:43:08 -0500
In-Reply-To: <497B1E5E.9050309@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So.. am I right that an IP address is a HOST property, not an INTERFACE
> property, and that the traditional way is just more convenient to set up? And
> that all the tools that complains that "there's no IP address assigned to this
> interface" (tcpdump) are wrong? :)

There are two "schools" of thought - the Linux stack follows the "weak end 
system" model in which IP addresses are treated as a host property.  There is 
another school of thought called the "strong end system" model where IP addresses 
are an interface property.  There are some "other" stacks out there which can be 
configured to behave in a "strong end system" way but they tend to default to 
more of something in between the two.

Tcpdump may simply be caught in the middle :)

rick jones
