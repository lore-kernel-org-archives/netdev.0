From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 13:18:35 +0100
Message-ID: <87ocy7e95w.fsf@basil.nowhere.org>
References: <8CB452A85703FEF-9E4-FEB@FWM-M04.sysops.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jpo234@netscape.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39205 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbZAPMTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 07:19:17 -0500
In-Reply-To: <8CB452A85703FEF-9E4-FEB@FWM-M04.sysops.aol.com> (jpo234@netscape.net's message of "Thu, 15 Jan 2009 08:15:50 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jpo234@netscape.net writes:

> Hello all,
> the IPv4 socket interface had the nifty IP_HDRINCL option. It seems
> that an IPv6 version of this option is not available. The proposed
> solution for this seems to be to use libpcap to inject the
> packet. Unfortunately this completely bypasses both, netfilter and
> IPsec. So, am I lost or is there a way to do what I want/need?

The theory is (the same on IPv4) is that the socket options should
allow you to specify everything legal you could put into a IPv6 header
by hand. 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
