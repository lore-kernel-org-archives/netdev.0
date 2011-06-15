From: Antoine Reversat <a.reversat@gmail.com>
Subject: Re: [Bugme-new] [Bug 37172] New: Enabling 802.1q vlan causes some
 packets to be received with a vlan id of 64
Date: Wed, 15 Jun 2011 12:57:43 -0400
Message-ID: <BANLkTi=8G+CeP5qD1mUA5xSbASYG33TviQ@mail.gmail.com>
References: <bug-37172-10286@https.bugzilla.kernel.org/>
	<20110613164355.c4f7b7b2.akpm@linux-foundation.org>
	<BANLkTi=Omr+oe3nMiqVeS+8tiSJnxONbhQ@mail.gmail.com>
	<BANLkTikU=78h1BcVm7akgE3PxRP5eb57gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40708 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab1FOQ5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 12:57:44 -0400
Received: by bwz15 with SMTP id 15so630328bwz.19
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2011 09:57:43 -0700 (PDT)
In-Reply-To: <BANLkTikU=78h1BcVm7akgE3PxRP5eb57gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2011 at 12:13 PM, Antoine Reversat <a.reversat@gmail.com> wrote:
> I've tested 2.6.37.6 and 3.0.0-rc2 and the bug is still reproducible
> in both kernels. I'll try a 2.6.36 to see if it was present in it too.
>
> Has this been tested on other hardware ? I'm still unsure if it's a
> driver issue or if it's something else.
>

Infact it's probably a driver bug : I've tried on a coworkers computer
with a different network adapter and it works flawlessly. I'll contact
the forcedeth people about this.
