From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] ipv4: Fix runtime WARNING in rtmsg_ifa()
Date: Wed, 5 Feb 2014 09:30:25 -0800
Message-ID: <CAHA+R7Pw_A4SLVL5=3i47MeMiYAgMRTTyWV5yN5c6LmGvWbTGA@mail.gmail.com>
References: <1391585905-24851-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:45412 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbaBERa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 12:30:27 -0500
Received: by mail-la0-f49.google.com with SMTP id y1so568290lam.8
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 09:30:26 -0800 (PST)
In-Reply-To: <1391585905-24851-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 4, 2014 at 11:38 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> Apparently commit 5c766d642bcaffd0c2a5b354db2068515b3846cf ("ipv4:
> introduce address lifetime") forgot to take into account the addition of
> struct ifa_cacheinfo in inet_nlmsg_size(). Hence add it, like is already
> done for ipv6.
>
> Suggested-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Signed-off-by: Cong Wang <cwang@twopensource.com>

Seems a candidate for -stable.
