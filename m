From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Fri, 21 Sep 2007 10:08:33 -0400
Message-ID: <780b6f780709210708k59c7b9al6d1241bac8419a5b@mail.gmail.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	 <36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	 <20070918020358.d50653d5.billfink@mindspring.com>
	 <ygfps0g8lj0.fsf@janus.isnogud.escape.de> <82k5qoxfbk.fsf@mid.bfk.de>
	 <780b6f780709180932j5944b927p44ace42833e0230b@mail.gmail.com>
	 <08FE5CC30C9A3F41BF819A502CF7BF6E02045257@fmsmsx411.amr.corp.intel.com>
	 <780b6f780709190753qd52d099id937a6c75e5d560e@mail.gmail.com>
	 <20070919225105.1e80e91d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Bill Fink" <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:33018 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759513AbXIUOIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 10:08:35 -0400
Received: by wa-out-1112.google.com with SMTP id v27so995537wah
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 07:08:34 -0700 (PDT)
In-Reply-To: <20070919225105.1e80e91d.billfink@mindspring.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/19/07, Bill Fink <billfink@mindspring.com> wrote:
> Just my personal opinion, but unless you want to do more testing,
> since you now seem to have a working setup, I would tend to leave
> it the way it is.
Quite sensible, yes. Performance even seems to be good - I am getting
40-40MBps reads and 24-26MBps writes - so it'll stay the way it is.

> By any chance did you happen to power cycle some equipment in this
> process that you didn't previously power cycle during earlier testing
> and debugging?  If so, perhaps that hardware had somehow gotten into
> a funky state, and the power cycling might have cleared it up.
Not that I am aware of: one of the first things that I did - and
repeated basically every step of the way - was to powercycle the two
switches, following the same line of reasoning you did. The clients
were turned off every night and turned back on every morning and the
WAN Comcast CPE wasn't touched for the duration. The only thing that
did change is that in an impetus of efficiency or perhaps desperation
I changed that cable too (to CAT6, 3' long), but I can't imagine that
would affect the LAN side of operations.
Thanks again - to everyone - for the help. I am still puzzled, but at
least I am puzzled with a consistent situation.
To Mr. Romieu: the patch you provided seems to work, in that 'regular'
loads don't trip samba up. I have to check the CRCs, though.

>                                                 -Bill

Luigi Fabio
