From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: How to find I/F to destination
Date: Fri, 4 May 2007 17:16:57 +0400
Message-ID: <20070504131657.GA2291@2ka.mipt.ru>
References: <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59994 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754616AbXEDNRG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:17:06 -0400
Content-Disposition: inline
In-Reply-To: <5910.1178284095@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 02:08:15PM +0100, David Howells (dhowells@redhat.com) wrote:
> 
> Should route_get_raw() release the rtable if gets back?

Yes, dst entry should be released when not used anymore.

> David

-- 
	Evgeniy Polyakov
