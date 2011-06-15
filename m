From: Antoine Reversat <a.reversat@gmail.com>
Subject: Re: [Bugme-new] [Bug 37172] New: Enabling 802.1q vlan causes some
 packets to be received with a vlan id of 64
Date: Wed, 15 Jun 2011 12:13:50 -0400
Message-ID: <BANLkTikU=78h1BcVm7akgE3PxRP5eb57gw@mail.gmail.com>
References: <bug-37172-10286@https.bugzilla.kernel.org/>
	<20110613164355.c4f7b7b2.akpm@linux-foundation.org>
	<BANLkTi=Omr+oe3nMiqVeS+8tiSJnxONbhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48946 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704Ab1FOQNw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 12:13:52 -0400
Received: by bwz15 with SMTP id 15so594045bwz.19
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2011 09:13:51 -0700 (PDT)
In-Reply-To: <BANLkTi=Omr+oe3nMiqVeS+8tiSJnxONbhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've tested 2.6.37.6 and 3.0.0-rc2 and the bug is still reproducible
in both kernels. I'll try a 2.6.36 to see if it was present in it too.

Has this been tested on other hardware ? I'm still unsure if it's a
driver issue or if it's something else.

On Tue, Jun 14, 2011 at 9:31 AM, Antoine Reversat <a.reversat@gmail.com=
> wrote:
> On Mon, Jun 13, 2011 at 7:43 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>>
>> From which kernel version did we regress? =A0Was 2.6.38 OK?
>
> I can confirm this bug is present in 2.6.38.6
>
> I'll try and see if I can reproduce it on a 2.6.37
>
