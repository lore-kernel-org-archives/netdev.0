From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] IP_GRE: Fix IP-Identification.
Date: Thu, 21 Feb 2013 19:42:31 -0800
Message-ID: <CALnjE+qOTnzdEjuGheRBhVC9piHdVKornV4Fv=ZubKS6ZAF6gQ@mail.gmail.com>
References: <1361499519-1715-1-git-send-email-pshelar@nicira.com>
	<1361500507.32484.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:42162 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755183Ab3BVDmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 22:42:32 -0500
Received: by mail-vc0-f197.google.com with SMTP id gb30so377199vcb.8
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 19:42:31 -0800 (PST)
In-Reply-To: <1361500507.32484.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 6:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-02-21 at 18:18 -0800, Pravin B Shelar wrote:
>> Use ip_select_ident_more() to generate and account ids for all
>> segments that can be used for segments of a gso packet.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> I am not sure it makes any sense to do that.
>
> Why is it needed ?
>

Without this patch GRE-GSO generates ip fragments with id 0,2,3,4...
for every GSO packet, which is not correct. This patch fixes it.
