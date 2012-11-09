From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: Question about Mellanox FW reporting (incorrect) port types
Date: Fri, 09 Nov 2012 18:37:34 -0200
Message-ID: <509D698E.60000@redhat.com>
References: <507EDC5D.4070602@redhat.com> <CAJZOPZ+T7paqVe12n+sBw4ra8AEWCZ+W2GZ52iJY=9Hrgoxuaw@mail.gmail.com> <507F0BD5.7080005@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Yishai Hadas <yishaih@dev.mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5480 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab2KIUhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 15:37:55 -0500
In-Reply-To: <507F0BD5.7080005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 17-10-2012 16:49, Marcelo Ricardo Leitner escreveu:
> On 10/17/2012 04:22 PM, Or Gerlitz wrote:
>> Marcelo Ricardo Leitner <mleitner@redhat.com> wrote:
>>>
>>> [...] So my questions are: is it possible to the firmware report a
>>> wrong port type like
>>> that? Is it somehow configurable by sysadmin (via fw update, ..), can
>>> we flip that byte
>>> or is it a manufacturing issue?

For completeness,

As it happens the customer had the HP Infinband Enablement Kit 
(614841-B21) installed at jumper location 53 (J53) of the motherboard, 
which makes the QSFP port of the S390s' NC543i interface an Infiniband 
interface rather than a 10gbE interface. Removing this allowed the port 
to be brought-up as 10GbE just fine.

Interesting that it worked as 10GbE even with InifiniBand Enablement Kit 
on it, so the port was just advertised, but not forced, as InfiniBand. 
Or something like that.

Thanks,
Marcelo.
