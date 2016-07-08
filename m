From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/2] libxt_hashlimit: Prepare libxt_hashlimit.c for
 revision 2
Date: Fri, 8 Jul 2016 16:37:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4F3704@AcuExch.aculab.com>
References: <20160707233419.GC5026@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "johunt@akamai.com" <johunt@akamai.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pai.vishwain@gmail.com" <pai.vishwain@gmail.com>
To: 'Vishwanath Pai' <vpai@akamai.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:54701 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755636AbcGHQjr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:39:47 -0400
In-Reply-To: <20160707233419.GC5026@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vishwanath Pai
> Sent: 08 July 2016 00:34
> I am planning to add a revision 2 for the hashlimit xtables module to
> support higher packets per second rates. This patch renames all the
> functions and variables related to revision 1 by adding _v1 at the end of
> the names.

Sounds backwards.
If you need to change the default, and are changing all the callers,
the just change it.

If you think some users would still want 32bit limits, then you should
(probably) use a _64 suffix for the new functions.

	David
