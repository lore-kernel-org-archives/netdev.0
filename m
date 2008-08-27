From: Hans de Goede <j.w.r.degoede@hhs.nl>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 11:14:17 +0200
Message-ID: <48B51AE9.5080709@hhs.nl>
References: <bug-459782-176318@bugzilla.redhat.com> <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com> <20080826163719.GA25066@redhat.com> <48B44C3F.6020006@cosmosbay.com> <48B452ED.1000308@hhs.nl> <48B469EA.1010807@cosmosbay.com> <48B46E89.4030104@hhs.nl> <48B47543.8080701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.versatel.nl ([62.58.50.89]:33063 "EHLO smtp2.versatel.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214AbYH0JDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:03:07 -0400
In-Reply-To: <48B47543.8080701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> 
> I dont know, you tell us 50x, but nowhere I saw your numbers on i386,
> nor the amount of memory of your test machine.
> 

My machine has 2 Gb of memory, but that is not really relevant as I'm not the 
reporter of the problem (but I can reproduce it) I'm only in the loop because I 
maintain the gkrellm package in Fedora which exhibits this problem. Also I gave 
you no i386 numbers on the same machine because I don't have an i386 install 
readily available on this machine.

Now you can spin this anyway you want, but lets cut to the chase, gkrellmd 
which is a system monitoring daemon reads /proc/net/tcp and /proc/net/tcp6 3 
times a second, with slightly older kernel this used to give a CPU load of
2-3% on x86_64 now it gives a load of 50-70% (on my test machine with a whole 8 
tcp connections open).

Now you can wing it any way you want, but this is a serious regression. I don't 
want to go to lkml and start shouting regression REGRESSION regression, but 
given the treating and enormous amount of help I've received sofar (and 
remember I'm only the messenger I didn't write nor use gkrellmd) I'm tending 
towards starting shouting regression on lkml, as atleast there this seems to 
get some attention.

Regards,

Hans
