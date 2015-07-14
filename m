From: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Subject: RE: [PATCH] brouted packet identified as PACKET_OTHERHOST blocked
 by higher protocol
Date: Tue, 14 Jul 2015 11:18:27 +0000
Message-ID: <3167EFAB95044A4EB6B134B9A39AA98A055B5E50@xmb-rcd-x05.cisco.com>
References: <3167EFAB95044A4EB6B134B9A39AA98A055B5DBE@xmb-rcd-x05.cisco.com>
 <20150714110501.GC25674@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-3.cisco.com ([173.37.142.90]:57390 "EHLO
	alln-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbbGNL1v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 07:27:51 -0400
Received: from xhc-aln-x10.cisco.com (xhc-aln-x10.cisco.com [173.36.12.84])
	by rcdn-core-3.cisco.com (8.14.5/8.14.5) with ESMTP id t6EBIS6M027692
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 11:18:28 GMT
In-Reply-To: <20150714110501.GC25674@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> wrote:
> Yigal Reiss (yreiss) <yreiss@cisco.com> wrote:
> > The problem I'm trying to solve is that when packets being sent from
> one bridged interface to the other are "brouted" they get dropped by the
> IP layer. The reason is that the packet being raised has pkt_type of
> type PACKET_OTHERHOST.
> 
> No, thats not the problem you're trying to solve.
> 
> If you want to move OTHERHOST skbs, don't (b)route them?
> 
> Whats the real issue that you're trying to solve?

I want to (b)route them because I want to be able to inspect the packets in higher levels
(through iptables or user space IPS).

Once I do that (i.e. (b)route by applying an appropriate ebtables rule), the corresponding
packets get dropped unless I apply the patch.
