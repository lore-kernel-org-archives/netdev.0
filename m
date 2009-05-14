From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Kernel panic in inet_twdr_do_twkill_work
Date: Thu, 14 May 2009 02:13:32 -0700
Message-ID: <m18wl0nj2b.fsf@fess.ebiederm.org>
References: <m17i0ktr4p.fsf@fess.ebiederm.org> <4A0BCE0E.3000206@free.fr>
	<m1y6t0nlle.fsf@fess.ebiederm.org> <4A0BD750.4030605@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54549 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbZENJNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 05:13:36 -0400
In-Reply-To: <4A0BD750.4030605@free.fr> (Daniel Lezcano's message of "Thu\, 14 May 2009 10\:33\:20 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> May be you can activate the NETNS_REFCNT_DEBUG in order to check if the timewait
> socket
> were destroyed at the namespace destruction ? Unfortunately it looks like the
> option is not in the Kconfig :(

Looks like a good starting place.

I will enable that when I respin my internal kernel.

I don't have a good reproducer at the moment....  So I was hoping we could
figure this out with code inspection.

Eric

