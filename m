From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Kernel panic in inet_twdr_do_twkill_work
Date: Sun, 24 May 2009 15:26:33 +0200
Message-ID: <4A194B09.7070900@free.fr>
References: <m17i0ktr4p.fsf@fess.ebiederm.org> <4A0BCE0E.3000206@free.fr>	<m1y6t0nlle.fsf@fess.ebiederm.org> <4A0BD750.4030605@free.fr> <m18wl0nj2b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:40305 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbZEXN13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 09:27:29 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.14.3/8.13.8) with ESMTP id n4ODQZhu448086
	for <netdev@vger.kernel.org>; Sun, 24 May 2009 13:26:35 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4ODQZpx3018756
	for <netdev@vger.kernel.org>; Sun, 24 May 2009 15:26:35 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4ODQZKn025702
	for <netdev@vger.kernel.org>; Sun, 24 May 2009 15:26:35 +0200
In-Reply-To: <m18wl0nj2b.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>
>   
>> May be you can activate the NETNS_REFCNT_DEBUG in order to check if the timewait
>> socket
>> were destroyed at the namespace destruction ? Unfortunately it looks like the
>> option is not in the Kconfig :(
>>     
>
> Looks like a good starting place.
>
> I will enable that when I respin my internal kernel.
>
> I don't have a good reproducer at the moment....  So I was hoping we could
> figure this out with code inspection.
>   
Hi Eric,

did you succeeded to reproduce the bug with the test program I sent you ?

