From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] brouted packet identified as PACKET_OTHERHOST blocked by
 higher protocol
Date: Tue, 14 Jul 2015 13:05:01 +0200
Message-ID: <20150714110501.GC25674@breakpoint.cc>
References: <3167EFAB95044A4EB6B134B9A39AA98A055B5DBE@xmb-rcd-x05.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48915 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752044AbbGNLFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 07:05:03 -0400
Content-Disposition: inline
In-Reply-To: <3167EFAB95044A4EB6B134B9A39AA98A055B5DBE@xmb-rcd-x05.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yigal Reiss (yreiss) <yreiss@cisco.com> wrote:
> The problem I'm trying to solve is that when packets being sent from one bridged interface to the other are "brouted" they get dropped by the IP layer. The reason is that the packet being raised has pkt_type of type PACKET_OTHERHOST.

No, thats not the problem you're trying to solve.

If you want to move OTHERHOST skbs, don't (b)route them?

Whats the real issue that you're trying to solve?
