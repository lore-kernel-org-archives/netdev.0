From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Update of the r8169 branch
Date: Fri, 22 Sep 2006 23:00:31 +0200
Message-ID: <20060922210031.GA30761@electric-eye.fr.zoreil.com>
References: <20060726215840.GA4032@electric-eye.fr.zoreil.com> <4511A4F0.6050101@kernelpanic.ru> <20060920214010.GA7879@electric-eye.fr.zoreil.com> <4512B475.1000703@kernelpanic.ru> <20060921165156.GC496@electric-eye.fr.zoreil.com> <4512ED7A.40001@kernelpanic.ru> <20060921210743.GA5083@electric-eye.fr.zoreil.com> <451431B7.3080608@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, mbockol@carleton.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48615 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S965017AbWIVVCW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 17:02:22 -0400
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Content-Disposition: inline
In-Reply-To: <451431B7.3080608@kernelpanic.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Boris B. Zhmurov <bb@kernelpanic.ru> :
[...]
> Thanks Francois, after your suggestions, network performance was twice 
> increased, but I'm still loosing to freebsd:

Ok, now that the Linux kernel is not in heavy debugging mode, it takes
some ~10 us/(sent packet). It is not _too_ far from the usual syscall
tax.

Can you send a typical excerpt of an 'strace -T' for your client iperf
process and compare it against the FreeBSD one ?

[...]
> P.S. I couldn't disable the following things due to bzImage build errors:
> CONFIG_GENERIC_TIME
> CONFIG_X86=y
> CONFIG_MMU=y
> CONFIG_GENERIC_IOMAP=y
> CONFIG_DMI=y

Oops, I was a bit terse: you were only supposed to disable the outlined
options (i.e. mostly debugging and/or unneeded stuff). As long as the
kernel performs better, it should not be a big issue though.

-- 
Ueimor
