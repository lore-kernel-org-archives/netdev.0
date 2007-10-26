From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] NET: Mark snmp4_icmp_list[] as being unused
Date: Thu, 25 Oct 2007 18:27:22 -0700
Message-ID: <OF4EE0CEBB.1648619D-ON88257380.00077574-88257380.0007E67A@us.ibm.com>
References: <23686.1193353513@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:40290 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627AbXJZB10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 21:27:26 -0400
In-Reply-To: <23686.1193353513@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dhowells@redhat.com wrote on 10/25/2007 04:05:13 PM:

> David Stevens <dlstevens@us.ibm.com> wrote:
> 
> > What about just removing it, or do you think it's
> > useful for documentation of the order? Either way,
> 
> I don't know whether it's intended to be used for something, perhaps a
> debugging macro.  Perhaps it should be #if'd out instead.

        It was used for /proc/net/snmp header printing, but
most of the items in it were moved to a different MIB (by me).
The new values are printed in a backward-compatible way, but
maintaining the old order means not using this header map.
        So, long-winded way of saying I believe it should be
removed, but I missed that when I made it obsolete. :-)

                                                        +-DLS

