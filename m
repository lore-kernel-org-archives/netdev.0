From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: Re: sky2 driver stopped working after upgrading from 2.6.18-4
Date: Sun, 13 Jan 2008 05:26:16 -0500
Message-ID: <76366b180801130226m124a0ab9o6f774a46ca4493db@mail.gmail.com>
References: <76366b180801130024j78225c66j17974245e86a183f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:8687 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbYAMK0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 05:26:17 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1436073rvb.1
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2008 02:26:16 -0800 (PST)
In-Reply-To: <76366b180801130024j78225c66j17974245e86a183f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears this problem might be caused by the system HPET timer not
functioning properly. I was noticing strange behavior in my rc0.d
shutdown scripts where the script would freeze in a 'sleep 1'. Sure
enough, even running a 'sleep 1' form a normal prompt just made the
system hang indefinitely (until I hit ctrl-C). If I unload sky2 and
then install a different clock source (jiffies, tsc, etc) and reload
the module, it all appears to work properly. This is very, very
strange. I'll bring this up on the kernel mailing list in a different
post focusing on the HPET config.

Thanks,
-Andrew

On Jan 13, 2008 3:24 AM, Andrew Paprocki <andrew@ishiboo.com> wrote:
> I have never been able to get my Yukon-EC Ultra (0xb4) rev 2 working
> on anything past 2.6.18-4 that I've tried. (All ~.20+)
