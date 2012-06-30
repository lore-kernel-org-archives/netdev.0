From: Michal Zatloukal <myxal.mxl@gmail.com>
Subject: Re: [BUG, regression, bisected] Marvell 88E8055 NIC (sky2) fails to
 detect link after resume from S3
Date: Sat, 30 Jun 2012 11:01:04 +0200
Message-ID: <CAKKZj2DVX7Kr4Ag7jubtr7fSa5sSLYR=kt2b6=PV=8fV6q0d8Q@mail.gmail.com>
References: <op.wgon84tw16tawo@esprimo>
	<20120629164610.1f343434@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f42.google.com ([209.85.213.42]:63465 "EHLO
	mail-yw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516Ab2F3JBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 05:01:05 -0400
Received: by yhfq11 with SMTP id q11so4857460yhf.1
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 02:01:04 -0700 (PDT)
In-Reply-To: <20120629164610.1f343434@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 30, 2012 at 1:46 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
<snip>
>
> Is ubuntu still doing the stupid rmmod on suspend?

The modprobes in the posted dmesg were done manually by me to see if
it would help. It didn't.
As for Ubuntu doing it, I don't know. Any way I could tell? I've
looked into /usr/lib/pm-utils/pm-functions and the $SUSPEND_MODULES
variable is set to empty, so it doesn't look like it's doing it for
any modules at this point.

> Looks like PCI power management has turned the chip off (that is why it
> keeps reading ff to all requests).

Is there something I can try?

MZ
