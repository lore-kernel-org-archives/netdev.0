From: Andrew Morton <akpm@osdl.org>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 13:35:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512133520.44fbfd39.akpm@osdl.org>
References: <20040512020700.6f6aa61f.akpm@osdl.org>
	<20040512181903.GG13421@kroah.com>
	<40A26FFA.4030701@pobox.com>
	<20040512193349.GA14936@elte.hu>
	<Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
	<20040512200305.GA16078@elte.hu>
	<20040512132050.6eae6905.akpm@osdl.org>
	<40A28815.2020009@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, davidel@xmailserver.org, greg@kroah.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40A28815.2020009@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> > How about we do:
>  > 
>  > #if HZ=1000
>  > #define	MSEC_TO_JIFFIES(msec) (msec)
>  > #define JIFFIES_TO_MESC(jiffies) (jiffies)
>  > #elif HZ=100
>  > #define	MSEC_TO_JIFFIES(msec) (msec * 10)
>  > #define JIFFIES_TO_MESC(jiffies) (jiffies / 10)
>  > #else
>  > #define	MSEC_TO_JIFFIES(msec) ((HZ * (msec) + 999) / 1000)
>  > #define	JIFFIES_TO_MSEC(jiffies) ...
>  > #endif
>  > 
>  > in some kernel-wide header then kill off all the private implementations?
> 
> 
>  include/linux/time.h.  One of the SCTP people already did this, but I 
>  suppose it's straightforward to reproduce.

OK, I'll do it.
