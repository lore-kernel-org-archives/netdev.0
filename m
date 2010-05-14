From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Fri, 14 May 2010 10:54:50 -0700
Message-ID: <C812DC7A.31859%scofeldm@cisco.com>
References: <20100514173530.GI5798@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Arnd Bergmann <arnd@arndb.de>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:4609 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757586Ab0ENRyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 13:54:53 -0400
In-Reply-To: <20100514173530.GI5798@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/14/10 10:35 AM, "Chris Wright" <chrisw@redhat.com> wrote:

> Patrick layed out some nice details before.  Here's the link:
> 
> http://thread.gmane.org/gmane.linux.network/151605/focus=151738

Double drats, it looks like that one was caught too late.  So we're
collectively agreeing to let a known bad netlink msg in?  I guess it can be
fixed up later with a IFLA_VF_INFOS nest, and move away from the broken
msgs.

-scott

