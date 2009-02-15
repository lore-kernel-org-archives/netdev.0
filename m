From: Teran McKinney <sega01@gmail.com>
Subject: Re: net.ipv6.conf.INT.accept_ra_rt_info_max_plen defaults to 0
Date: Sun, 15 Feb 2009 14:05:03 +0000
Message-ID: <b245135e0902150605q1bbaddc3pa3dd6053e158ae2e@mail.gmail.com>
References: <alpine.LRH.2.00.0902030632240.7583@netcore.fi>
	 <20090202.213616.258001767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f11.google.com ([209.85.221.11]:52583 "EHLO
	mail-qy0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbZBOOFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 09:05:05 -0500
Received: by qyk4 with SMTP id 4so2534180qyk.13
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2009 06:05:03 -0800 (PST)
In-Reply-To: <20090202.213616.258001767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

I personally think that 64 would be a reasonable default route length,
but am currently setting it to 120 in Icadyptes to be safe (probably
closer to excessive). More so, I'm just happy that it is supported,
even though it is disabled by default. Few people use it in the first
place, and I don't see what harm it could bring other than alternative
perspectives on potential security issues that already exist in NDP.

@Pekka: Thanks for bringing this up. I think a short note in
radvd.conf.example might help, but I should do a blog post so that
Google is more useful if you aren't searching with exactly the right
terminology.

Thanks,
Teran

On Tue, Feb 3, 2009 at 05:36, David Miller <davem@davemloft.net> wrote:
> From: Pekka Savola <pekkas@netcore.fi>
> Date: Tue, 3 Feb 2009 06:38:49 +0200 (EET)
>
>> As reported and discussed below and in
>> <http://www.mail-archive.com/debian-ipv6@lists.debian.org/msg03753.html>,
>> to accept "route information option" on Linux, you have to manually
>> change accept_ra_rt_info_max_plen sysctl value.  Other
>> implementations that I know of accept this by default.
>>
>> Is it intentional that Route Information options are ignored by default?
>>
>> I suspect not -- if so, the default value should be (IMHO) 64 or if
>> that's disagreeable, 48.
>>
>> Even if this is intentional, I think the intentions should be revisited.
>
> It looks very intentional, both via the code and it's documentation
> in ip-sysctl.txt
>
> It seems that it is disabled like this by default when
> accept_ra_rtr_pref is enabled, and that seems pretty reasonable to me.
>
> I'm sure whoever made that decision didn't do so on a whim and had
> a very good reason for it.
>
