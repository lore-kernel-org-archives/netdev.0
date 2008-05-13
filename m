From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 13/16] myri10ge: add routines for multislices
Date: Tue, 13 May 2008 20:34:59 +0200
Message-ID: <4829DF53.3080600@myri.com>
References: <482397A3.1050604@myri.com> <482398F6.3060902@myri.com> <48292B82.5090304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1999 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753107AbYEMSfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 14:35:09 -0400
In-Reply-To: <48292B82.5090304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Brice Goglin wrote:
>> Add several routines that multislices support will use.
>>
>> Signed-off-by: Brice Goglin <brice@myri.com>
>> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
>> ---
>>  drivers/net/myri10ge/myri10ge.c |  256
>> ++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 256 insertions(+)
>
> this is not really appropriate for the bug-fixes-only 2.6.26-rc.
>
> I temporarily put patches 13-16 in netdev-2.6.git#upstream-myri, and
> will shove them into net-next once davem pulls in the myri bugfixes
> into net-next (or you guys have some alternate suggestions)

Actually, if #16 (update driver version) isn't going to Linus soon,
there is no need to keep it for now. It will very probably be outdated
when the 2.6.27 release cycle will start. So I'll send an updated one
for then (and I may send an updated one for 2.6.26 later also). So
please drop this #16 from upstream-myri.

By the way, there is no MAINTAINERS entry for myri10ge, so here's one in
the next patch.

thanks,
Brice

