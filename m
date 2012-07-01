From: Michal Zatloukal <myxal.mxl@gmail.com>
Subject: Re: [BUG, regression, bisected] Marvell 88E8055 NIC (sky2) fails to
 detect link after resume from S3
Date: Sun, 1 Jul 2012 15:30:12 +0200
Message-ID: <CAKKZj2DZprXcEg1tRDnt9fnFahLnOEMQNno9hS2UJzQ-n13JHA@mail.gmail.com>
References: <op.wgon84tw16tawo@esprimo>
	<20120629164610.1f343434@nehalam.linuxnetplumber.net>
	<CAKKZj2DVX7Kr4Ag7jubtr7fSa5sSLYR=kt2b6=PV=8fV6q0d8Q@mail.gmail.com>
	<20120630200236.GA30058@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:59277 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932326Ab2GANaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 09:30:13 -0400
Received: by obbuo13 with SMTP id uo13so6643168obb.19
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 06:30:13 -0700 (PDT)
In-Reply-To: <20120630200236.GA30058@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breaking news:
Fiddling with mmiotrace, I was able to get the "phy I/O error" on
previously-thought-good kernel (non-reliably; it took several
suspend-resume cycles), and also vice versa - in vty, I was able to
suspend and resume the "bad" kernel with the NIC still working (also
not reliably - in GUI, it still flaked out after first
suspend-resume).

Anyway, I've gathered traces of both good and bad behaviour, each from
the respective kernel (not that it seems to matter much). Now, what's
the recommended way of posting them? Each is over 3MB in size and
pastebin won't take them. :-(

MZ

On Sat, Jun 30, 2012 at 10:02 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Michal Zatloukal <myxal.mxl@gmail.com> :
> [...]
>> Is there something I can try?
>
> I have not used it for quite some time but comparing mmiotrace output
> (see Documentation/trace/mmiotrace.txt) before and after the regression
> commit may give some hint.
>
> Otherwise I would ask for help on linux-pm@vger.kernel.org
>
> --
> Ueimor
