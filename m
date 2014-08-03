From: Peter Moody <pmoody@google.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sat, 02 Aug 2014 19:38:05 -0700
Message-ID: <r3nr40yjo1e.fsf@perdido.sfo.corp.google.com>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
	<87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com>
	<lrhr02$ncj$1@ger.gmane.org> <r3nzjfmjr07.fsf@perdido.sfo.corp.google.com>
	<lrk4f5$4vo$2@ger.gmane.org> <r3nvbqajovk.fsf@perdido.sfo.corp.google.com>
	<lrk6or$unu$2@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Alex Elsayed <eternaleye@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <lrk6or$unu$2@ger.gmane.org> (Alex Elsayed's message of "Sat\, 02
	Aug 2014 19\:28\:43 -0700")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sat, Aug 02 2014 at 19:28, Alex Elsayed wrote:

> Oh, I see now. Okay, that's actually considerably simpler - I just had 
> somehow gotten it fixated into my mind that the info would be used to decide 
> on allow/deny actions.
>
> The trick to do what you want is the 'audit' support in both - 
> here I'll use CaitSith as an example since the syntax is nicer.

Do these audit logs end up with the audit subsystem? My experience with
the audit subsystem is that performance takes a big hit when you start
sending thousands (or even hundreds) of audit messages per second.

> In the header of a CaitSith policy, you specify resource limits for audit 
> logs in the format

I will definitely check out caitsith though. I think I saw Tetsuo talk
about it at LSS in San Diego a few years ago.
