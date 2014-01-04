From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/6] phy: kill excess code
Date: Sat, 04 Jan 2014 19:24:19 +0300
Message-ID: <52C835B3.80103@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>	<201401040419.14818.sergei.shtylyov@cogentembedded.com> <CAGVrzcadLFE-FWvgDQE5gkd6COZkGs2Q4SQdnOdKE4Deu-qa0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:47561 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242AbaADPYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 10:24:17 -0500
Received: by mail-la0-f53.google.com with SMTP id mc6so8681733lab.26
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 07:24:16 -0800 (PST)
In-Reply-To: <CAGVrzcadLFE-FWvgDQE5gkd6COZkGs2Q4SQdnOdKE4Deu-qa0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/04/2014 01:12 PM, Florian Fainelli wrote:

>  > Remove tens of lines of unnecessary code:

>  > - kill empty lines between a function call and its result check;

>  > - convert assignments to initializers;

>  > - kill useless assignments before *return*;

>  > - kill excess empty lines.

> I might be completely out of date on what checkpatch is picky about these days

    Yes, you probably are.

> but it seems to me like all of these changes would trigger new warnings, I

    No new warnings were added. You should really have checked before you 
spoken out.

> will take a closer look, but for now I don't see this patch making any
> reability improvements, quite the contrary.

    Apparently, tastes vary. To me, e.g. empty lines between the function call 
and result (error) check are a waste of space which is avoided by all other 
kernel code I had to read.

>  > Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com
> <mailto:sergei.shtylyov@cogentembedded.com>>

>  > ---
>  >  drivers/net/phy/phy.c        |   31 ++++------------------------
>  >  drivers/net/phy/phy_device.c |   46
> +++++++------------------------------------
>  >  2 files changed, 13 insertions(+), 64 deletions(-)

    May I ask you not to quote the full patch if you're replying only to the 
header? Please show some respect to people who read your messages.

WBR, Sergei
