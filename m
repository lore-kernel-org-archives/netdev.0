From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RTL-8110SC lockup with r8169
Date: Thu, 6 May 2010 22:20:55 +0200
Message-ID: <20100506202055.GB3541@electric-eye.fr.zoreil.com>
References: <4BE1973D.8080502@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Glen Gray <glen@lincor.com>
To: =?utf-8?Q?P=C3=A1draig?= Brady <P@draigBrady.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 97.17.115-78.rev.gaoland.net ([78.115.17.97]:59985 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753028Ab0EFUVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 16:21:08 -0400
Content-Disposition: inline
In-Reply-To: <4BE1973D.8080502@draigBrady.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

P=C3=A1draig Brady <P@draigBrady.com> :
[...]
> However the above code wasn't in the 2.6.32.10-90.fc12 driver we used=
=2E
> Also I've back-ported the latest r8169 driver from git to our kernel
> and it still has the same issue.

"latest" as "includes 908ba2bfd22253f26fa910cd855e4ccffb1467d0" ?

Otherwise you may save some time and try directly the backport at :
http://userweb.kernel.org/~romieu/r8169/2.6.32.11-99.fc12/

> # dmesg | grep 8169
> # lspci -n | grep -v 8086:
> 01:04.0 0200: 10ec:8167 (rev 10)

8167 how comes...

Which hardware (lspci) is the host computer made of ?

--
Ueimor
