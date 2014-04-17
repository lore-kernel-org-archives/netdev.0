From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] net: Fix ns_capable check in sock_diag_put_filterinfo
Date: Thu, 17 Apr 2014 11:22:06 +0200
Message-ID: <534F9D3E.9050300@6wind.com>
References: <1360f6acc2064d49a41f2d993d05cdcf8a40fc06.1397709384.git.luto@amacapital.net> <1397712086.19600.2.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:42389 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbaDQJWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 05:22:09 -0400
Received: by mail-wi0-f175.google.com with SMTP id cc10so2621614wib.2
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 02:22:08 -0700 (PDT)
In-Reply-To: <1397712086.19600.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/04/2014 07:21, Eric Dumazet a =C3=A9crit :
> On Wed, 2014-04-16 at 21:41 -0700, Andy Lutomirski wrote:
>> The caller needs capabilities on the namespace being queried, not on
>> their own namespace.  This is a security bug, although it likely has
>> only a minor impact.
>>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
