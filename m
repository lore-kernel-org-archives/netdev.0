From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2 v2] ss: avoid passing negative numbers to malloc
Date: Wed, 13 Nov 2013 06:16:17 -0800
Message-ID: <1384352177.28458.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131113084642.GA23572@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33728 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094Ab3KMOQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 09:16:19 -0500
Received: by mail-pd0-f169.google.com with SMTP id y13so465769pdi.28
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 06:16:18 -0800 (PST)
In-Reply-To: <20131113084642.GA23572@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 09:46 +0100, Andreas Henriksson wrote:
> Example:
> 
> $ ss state established \( sport = :4060  or sport = :4061 or sport = :4062  or sport = :4063 or sport = :4064  or sport = :4065 or sport = :4066  or sport = :4067 \)  > /dev/null
> Aborted
> 
> In the example above ssfilter_bytecompile(...) will return (int)136.
> char l1 = 136; means -120 which will result in a negative number
> being passed to malloc at misc/ss.c:913.
> 
> Simply declare l1 and l2 as integers to avoid the char overflow.
> 
> This is one of the issues originally reported in http://bugs.debian.org/511720
> 
> Fix the same problem in other code paths as well (thanks to Eric Dumazet).
> 
> Reported-by: Andreas Schuldei <andreas@debian.org>
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks !
