From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 v2] ip: use rtnelink to manage mroute
Date: Mon, 17 Dec 2012 09:41:49 +0100
Message-ID: <50CEDACD.9010707@6wind.com>
References: <20121212102617.0a3249e4@nehalam.linuxnetplumber.net> <1355390202-6868-1-git-send-email-nicolas.dichtel@6wind.com> <20121214101004.56a1fb62@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35240 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798Ab2LQIlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 03:41:52 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so2551149bkw.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 00:41:51 -0800 (PST)
In-Reply-To: <20121214101004.56a1fb62@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/12/2012 19:10, Stephen Hemminger a =E9crit :
> On Thu, 13 Dec 2012 10:16:42 +0100
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> mroute was using /proc/net/ip_mr_[vif|cache] to display mroute entri=
es. Hence,
>> only RT_TABLE_DEFAULT was displayed and only IPv4.
>> With rtnetlink, it is possible to display all tables for IPv4 and IP=
v6. The output
>> format is kept. Also, like before the patch, statistics are displaye=
d when user specify
>> the '-s' argument.
>>
>> The patch also adds the support of 'ip monitor mroute', which is now=
 possible.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Applied. I had to clean up some merge conflicts because of applying y=
our
> patches out of order. It would help if you would recheck the version
> that I just pushed to git.
>
Your version is ok.
