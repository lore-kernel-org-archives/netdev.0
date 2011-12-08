From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: IPv6 defrag question ?
Date: Thu, 8 Dec 2011 10:12:11 +0100
Message-ID: <201112081012.13065.hans.schillstrom@ericsson.com>
References: <jec613b.4edd5c40857133156bf40cef475e9234@obelix.schillstrom.com> <4ED763EA.50307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Hans Schillstrom <hans@schillstrom.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:58623 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621Ab1LHJMR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 04:12:17 -0500
In-Reply-To: <4ED763EA.50307@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi 
While testing HMARK and IPv6 with nf_defrag_ipv6 (and nf_conntrack_ipv6 loaded) I can't see the defrag ?

>From what I can see nf_conntrack_reasm goes into PREROUTING with prio -400
and HMARK in PREROUTING with prio -150

I was expecting that the reasaembled packet whould reach HMARK not the fragments.

(Debug print from hmark)
HMARK() mark:489, hash:4d04eaa1, frag:1, nhoffs:30 plen:1408 (2008::10 - 1000::1)
HMARK() mark:489, hash:4d04eaa1, frag:1, nhoffs:0  plen:86 (2008::10 - 1000::1)

IPv4 do reassm. the packets not IPv6...

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
