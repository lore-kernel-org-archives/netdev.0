From: Mickael Chazaux <mickael.chazaux@gmail.com>
Subject: Hardware bridging for Distributed Switch Architecture (DSA)
Date: Wed, 9 Feb 2011 11:30:19 +0100
Message-ID: <AANLkTi=cNhtBaOFYMEoN8K0UZXyO+AEbPYR+SwGzskpe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34702 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618Ab1BIKaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 05:30:20 -0500
Received: by vws16 with SMTP id 16so1402vws.19
        for <netdev@vger.kernel.org>; Wed, 09 Feb 2011 02:30:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm interested in working on hardware bridging support for the
Distributed Switch Architecture (DSA).

I have a few questions about this patch [1] :

"(While the patch in itself works, the implementation is ugly, and I
don't see it being merged upstream in this form any time soon"

Why this? What needs to be done to clean it up, and have it in shape?

"While conceptually I think this is the way this should work (i.e. no
workflow changes for the system administrator) "

I have worked a bit on this subject too and concluded to the same idea.

" the code shouldn't be hooking directly into the bridge code at all.
Ideally, it should just be using a netlink interface providing this info:
- bridge port group creation/destruction
- adding/removing an interface to/from a bridge port group
- changing the STP state of an interface in a bridge port group"

Doesn't brctl already uses netlink to configure the bridge? Could you expand
a bit more on this?

I like this approach of automatically hardware-bridge ports if possible when
adding them to a bridge. Do you mean putting a specific API in netlink
for doing
the hardware bridging stuff ?

Regards,

Mickael

[1] http://patchwork.ozlabs.org/patch/16578/
