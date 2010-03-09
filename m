From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: Re: Kernel panic in fib_rules_lookup (kernel 2.6.32)
Date: Tue, 09 Mar 2010 21:39:31 +0300
Message-ID: <110261268159971@webmail88.yandex.ru>
References: <76131268155285@webmail84.yandex.ru> <9847503.232911268158922219.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward11.mail.yandex.net ([95.108.130.93]:46634 "EHLO
	forward11.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab0CISje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 13:39:34 -0500
In-Reply-To: <9847503.232911268158922219.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Stephen

09.03.10, 10:22, "Stephen Hemminger" <stephen.hemminger@vyatta.com>:

>  > Yes. Vanilla 2.6.32. We saw the same issue on at least 2.6.30.1 (as
>  > far as I know).
>  > 
>  
>  
>  iptables NETFLOW and ISG modules aren't in standard kernel (yet)
>     http://www.progtech.ru/~oleg/lISG/

Agreed. But they are only iptables modules, not patches. How can they
be related to functionality of routing (especially routing rules) subsystem?

Thank you.

P.S.: By the way, we're not using rules at all on this router:

0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

-- 
wbr, Oleg.
