From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] net: Fix inner_network_header assignment in skb-copy.
Date: Fri, 1 Feb 2013 17:14:43 -0800
Message-ID: <CALnjE+rpC8p3mZ4tdp+Ok792mvwSrMR-8YAH4vZyJSDVFevx1w@mail.gmail.com>
References: <1359764763-1618-1-git-send-email-pshelar@nicira.com>
	<CAP=VYLqYDLeLssrwizRGChygEPwLRSwXBh+YkSr4F7MW1XiGtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:43014 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756660Ab3BBBOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 20:14:43 -0500
Received: by mail-qa0-f69.google.com with SMTP id hy16so2040755qab.8
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 17:14:43 -0800 (PST)
In-Reply-To: <CAP=VYLqYDLeLssrwizRGChygEPwLRSwXBh+YkSr4F7MW1XiGtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 1, 2013 at 4:57 PM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> On Fri, Feb 1, 2013 at 7:26 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> Hi Pravin,
>
> As a general rule of thumb, a commit log should cover these three
> basic things:
>
> 1) What are the end user visible symptoms of this issue (i.e. does it panic,
> does it hang, do applications segfault, etc etc).
>
> 2) Why does this happen?  i.e. explain where the logic error is in the
> existing code base and so forth.
>
> 3) How do we best fix this?   i.e. explain what our options are to fix
> the issue, and why your choice of fixes is technically the best choice.
>
> With no long log whatsoever, your change does not cover any of
> the #1, #2 or #3.  And without that, it also makes review by the
> maintainers more difficult, and reduces the chance that your
> patch will be integrated into mainline.  Can you perhaps resend
> with a more detailed commit log, given the above information?
>

Well its trivial change so I did not wrote commit msg. Anyways I will
send patch with a commit msg.

Thanks,
Pravin.
