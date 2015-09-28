From: Matthew Dupre <Matthew.Dupre@metaswitch.com>
Subject: Per-flow IPv4 ECMP
Date: Mon, 28 Sep 2015 08:57:25 +0000
Message-ID: <BN1PR0201MB05777291EE3D91068CB2EE8E944F0@BN1PR0201MB0577.namprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0109.outbound.protection.outlook.com ([157.56.110.109]:48299
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757007AbbI1I51 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 04:57:27 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm interested in the Linux kernel's support for per-flow IPv4 ECMP (i.e. consistent path selection based on a hash of the connection tuple).  I'd been led to believe[1] that this depended on the route cache, which was removed in 3.6.

However, I tested a route with multiple next hops on a 3.10 and 3.13 kernel, and ECMP was per-flow!  Obviously I'm pleased that this was the case, but I'd like to understand why this is supported, and whether I can rely on it in future.

Could anyone give me a little clarification on whether this is now supported by some means other than the route cache, and whether that support is intended to be continued?

Thanks,
Matt

[1]: http://bird.network.cz/pipermail/bird-users/2014-February/008873.html
