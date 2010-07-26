From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Splice status
Date: Mon, 26 Jul 2010 15:41:25 +0800
Message-ID: <AANLkTi=cTV69OnJ8-c064nA-F1xaV11KixviuvNMPFrR@mail.gmail.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	<1278334254.2877.158.camel@edumazet-laptop> <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
	<1278388580.2466.305.camel@edumazet-laptop> <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
	<1279030308.2634.349.camel@edumazet-laptop> <EE71107DF0D1F24FA2D95041E64AB9E80114797BC8AB@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nick Piggin <npiggin@suse.de>
To: Ofer Heifetz <oferh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:47685 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab0GZHlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 03:41:46 -0400
Received: by qwh6 with SMTP id 6so4883613qwh.19
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 00:41:45 -0700 (PDT)
In-Reply-To: <EE71107DF0D1F24FA2D95041E64AB9E80114797BC8AB@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 25, 2010 at 10:47 PM, Ofer Heifetz <oferh@marvell.com> wrote:
> Hi Eric,
>
> Still trying to get better performance with splice, I noticed that when using splice there are twice the file size memcpy (placed a counter in memcpy), I verified it via samba file transfer and splice-fromnet/out.
>
> I also used the splice-fromnet/out and using ftrace I did notice that data is copied twice using these routines: skb_splice_bits, pipe_to_file.
>
> I thought that the main goal of splice is to refrain from one copy when moving data from network to file descriptor.
>
> If there are the same number of memcpy and context switches and in samba copy additional vfs overhead it makes sense that splice deteriates the samba overall write performance.
>

The support for SPLICE_F_MOVE is removed by Nick in commit
http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=485ddb4b9741bafb70b22e5c1f9b4f37dc3e85bd
.

Nick, can we add it back now?

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
