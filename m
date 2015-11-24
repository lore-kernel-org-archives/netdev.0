From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 24 Nov 2015 09:52:49 -0800
Message-ID: <CALx6S37AVnVxbcW=N451qH1VKiNJ1HZYEj8eqob-4hXWcHbD3g@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
	<CAEh+42jWN961Gg59xbdXiFj9u7=3vuFdyXkcr6iPJ92ZizPpGw@mail.gmail.com>
	<C40BE8378EF49C44B9184714DBC8EF29939A13AA@ORSMSX115.amr.corp.intel.com>
	<CALx6S36H4eyDg-Vv21X2GaGA+g=KfN6iHX=8uM2isEOnPTjs0Q@mail.gmail.com>
	<20151123171103.00007699@unknown>
	<CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
	<1448387015.235472.448970977.10694A74@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Singhai, Anjali" <anjali.singhai@intel.com>,
	Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Patil, Kiran" <kiran.patil@intel.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37403 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbbKXRwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 12:52:50 -0500
Received: by igcto18 with SMTP id to18so19661289igc.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 09:52:49 -0800 (PST)
In-Reply-To: <1448387015.235472.448970977.10694A74@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 9:43 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Tue, Nov 24, 2015, at 18:32, Tom Herbert wrote:
>> As you said this in only feedback and nobody is forcing anyone to do
>> anything. But encouraging HW vendors to provide generic mechanisms so
>> that your users can use whatever protocol they want is the exact
>> _opposite_ of punishing users, this is very much a pro-user direction.
>
> Some users will suffer worse performance in case we don't correctly set
> ip_summed for a specific protocol before we do the copy operations from
> user space into skbs but if they are always done in the driver.
>
Please be specific. Who are the users, what is exact performance
regression, what are specific protocols in question?

> Bye,
> Hannes
