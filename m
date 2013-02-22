From: pravin <pravin.shelar@gmail.com>
Subject: Re: [PATCH net-next] IP_GRE: Fix IP-Identification.
Date: Thu, 21 Feb 2013 23:17:52 -0800
Message-ID: <CANvJab134DidKmwjC9nBO4nxZjt3xiry4sg1OahVaM69HiDxFA@mail.gmail.com>
References: <1361499519-1715-1-git-send-email-pshelar@nicira.com>
	<1361500507.32484.8.camel@edumazet-glaptop>
	<CALnjE+qOTnzdEjuGheRBhVC9piHdVKornV4Fv=ZubKS6ZAF6gQ@mail.gmail.com>
	<1361513185.3683.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
	edumazet@google.com, jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:47025 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220Ab3BVHRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 02:17:54 -0500
Received: by mail-wi0-f169.google.com with SMTP id l13so1727870wie.0
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 23:17:52 -0800 (PST)
In-Reply-To: <1361513185.3683.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 10:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-02-21 at 19:42 -0800, Pravin Shelar wrote:
>
>> Without this patch GRE-GSO generates ip fragments with id 0,2,3,4...
>> for every GSO packet, which is not correct. This patch fixes it.
>> --
>
> I guess my question was more : Why dont we inherit ID from the inner
> packet ?
>
Its good idea. But we still need to get counter from dst if inner
packet is not ipv4.


> ip_select_ident_more() is a performance killer, as all cpus are going to
> access a shared counter in the dst.
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
