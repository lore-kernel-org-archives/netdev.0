From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: Issue with /etc/netns/${nsname}/hosts
Date: Wed, 2 Sep 2015 18:24:29 +0200
Message-ID: <55E722BD.70108@6wind.com>
References: <CA+pPspp_b+50Z6+VNr4Y4K2BguHJZ9ykKCZ8j3aaFRkBOrbZGA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: James Loosli <loosli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34525 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbbIBQYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 12:24:32 -0400
Received: by wicfx3 with SMTP id fx3so23361713wic.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 09:24:31 -0700 (PDT)
In-Reply-To: <CA+pPspp_b+50Z6+VNr4Y4K2BguHJZ9ykKCZ8j3aaFRkBOrbZGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/09/2015 01:23, James Loosli a =C3=A9crit :
> I seem to have an issue with using namespace-specific hosts files.
> Here's an example.
>
> I have different entries for foo.com in my hosts file for the
> namespace and the system-wide hosts file;
>
> root@server-01 Tue Sep 01 04:15:02pm
>> cat /etc/netns/nsXX-XXX-240-3/hosts | grep foo
> 1.2.3.4 foo.com
> root@server-01 Tue Sep 01 04:15:15pm
>> ip netns exec nsXX-XXX-240-3 cat /etc/hosts | grep foo
> 1.2.3.4 foo.com
> root@server-01 Tue Sep 01 04:15:19pm
>> cat /etc/hosts | grep foo
> 0.0.0.0 foo.com
>
> But when I try to get curl, ping or other utilities to use that hosts
> file entry, they ignore the namespace-specific file.
>
> root@server-01 Tue Sep 01 04:16:02pm
>> ip netns exec ns91-227-240-3 curl -vv foo.com
Probably a copy and paste error, but the netns name was nsXX-XXX-240-3 =
in your
example above.
Can you confirm?
