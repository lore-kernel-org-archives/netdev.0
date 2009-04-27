From: Karsten Keil <karsten-keil@t-online.de>
Subject: Re: [PATCH v2 0/3] [ISDN] Documentation patchset
Date: Mon, 27 Apr 2009 13:45:34 +0200
Message-ID: <200904271345.35345.karsten-keil@t-online.de>
References: <cover.1240489461.git.keil@b1-systems.de> <20090427.031323.64748515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout08.t-online.de ([194.25.134.20]:37586 "EHLO
	mailout08.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754508AbZD0Lpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 07:45:52 -0400
In-Reply-To: <20090427.031323.64748515.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Montag, 27. April 2009 12:13:23 David Miller wrote:
> From: Karsten Keil <karsten-keil@t-online.de>
> Date: Thu, 23 Apr 2009 14:24:21 +0200
>
> > Fixed one more typo and wrong From: lines.
> >
> > Add some useful documentation for the ISDN subsystem.
> > Orignal patches are from Tilman Schmidt.
> > I fixed some whitespace issues and added the URL for the CAPI 2.0 spec.
>
> This patch set does not apply at all to net-2.6

I do not understand this, the patches were created against Linus tree, but now 
I checked out the net-2.6 tree and tried to apply them and it was successful, 
no warnings, and indeed the affected files in Linus tree and in net-2.6 are 
the same versions. To be sure that no MTA problem hit us, I used the mails
which were sent back from the list.
net-2.6 git tree was updated 15 minutes ago.

Here what I did:

kkeil@pingi:/w_pingi/git/net-2.6> git status
# On branch master
nothing to commit (working directory clean)
kkeil@pingi:/w_pingi/git/net-2.6> git describe
v2.6.29-10830-g1c41e23
kkeil@pingi:/w_pingi/git/net-2.6> git am  /tmp/\[PATCH\ v2\ 1_3\]\ update\ 
Documentation_isdn_00-INDEX.mbox
Applying: update Documentation/isdn/00-INDEX
kkeil@pingi:/w_pingi/git/net-2.6> git am  /tmp/\[PATCH\ v2\ 2_3\]\ 
Documentation_isdn_INTERFACE.mbox
Applying: Documentation/isdn/INTERFACE.CAPI
kkeil@pingi:/w_pingi/git/net-2.6> git am  /tmp/\[PATCH\ v2\ 3_3\]\ Add\ 
reference\ to\ CAPI\ 2.mbox
Applying: Add reference to CAPI 2.0 standard


Karsten

