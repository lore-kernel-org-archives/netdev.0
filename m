From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 9/9] ixgbe: Cleanup holes in flags after removing several of them
Date: Thu, 19 Jul 2012 09:33:19 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F98@saturn3.aculab.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com> <1342643516-2696-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Alexander Duyck" <alexander.h.duyck@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45411 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752471Ab2GSIoz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 04:44:55 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22773-10 for <netdev@vger.kernel.org>;
 Thu, 19 Jul 2012 09:44:51 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1342643516-2696-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This change is just meant to defragment the flags as there are several
hole
> that have been introduced since several features, or the flags for
them,
> have been removed.

Doesn't this sort of change just make it difficult for people who are
looking at hexdumps of memory but don't have exactly the right header
file to hand?

It doesn't really gain anything much either.

I can (just) imagine reordering flags so that the commonly
tested ones are in the low bits so that they can be tested
with small immediate constants - saving an instruction.
But that isn't what is being done here.

	David
