From: shemminger@osdl.org
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Mon, 12 Jul 2004 20:35:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1107.63.170.215.71.1089689716.squirrel@www.osdl.org>
References: <40F34740.5040100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        "devik" <devik@cdi.cz>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <40F34740.5040100@trash.net>
To: "Patrick McHardy" <kaber@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Hi Dave,
>
> this patch replaces PSCHED_CLOCK_SOURCE by three new config options
> and fixes HTB compilation with CONFIG_NET_SCH_CLK_GETTIMEOFDAY.
> Patch compiles with all three options. If you like it I will also send
> you a 2.4 version.
>
> Regards
> Patrick
>

I have a patch (to the original) which replaces the arch dependant CPU stuff
with the arch neutral sched_clock() which although slightly
slower works on a x86_64 and ia64 as well.
