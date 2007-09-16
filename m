From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver and samba
Date: Sat, 15 Sep 2007 22:04:31 -0700
Message-ID: <46ECB95F.2090100@intel.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
 <46EAC25B.2060404@intel.com>
 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
 <46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com>
 <46EC2D5A.7080504@intel.com>
 <780b6f780709152106q3d7f1042t72126c1be16ed1fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: L F <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:51429 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbXIPFFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 01:05:07 -0400
Received: from ahkok-mobl.jf.intel.com ([71.182.85.189])
 by vms042.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JOG001IU3FP8643@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Sun, 16 Sep 2007 00:04:38 -0500 (CDT)
In-reply-to: <780b6f780709152106q3d7f1042t72126c1be16ed1fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L F wrote:
>>>>> tx_deferred_ok: 486
>> this one I wonder about, and might cause delays, I'll have to look
>> up what it exactly could implicate though.
> Please do and let me know. samba 3.0.26 helped, but the issue is
> still there.

ok, from the spec: tx_deferred_ok is what is in the DC stats register. DC stands
for "Deferred Count". This initially is meant to track how often the TX unit cannot
send because the medium is busy in a Half-Duplex link state.

To me it suggests that your speed is not full-duplex. Check `ethtool eth0` output
and see if your link is full duplex or not. also check previous kernel messages
and see what the e1000 driver posted there for link speed messages (as in "e1000:
 Link is UP speed XXX duplex YYY")

Cheers,

Auke
