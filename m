From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: Re: Kernel panic in fib_rules_lookup (kernel 2.6.32)
Date: Tue, 09 Mar 2010 20:21:25 +0300
Message-ID: <76131268155285@webmail84.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward15.mail.yandex.net ([95.108.130.119]:52996 "EHLO
	forward15.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173Ab0CIRVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 12:21:37 -0500
Received: from webmail84.yandex.ru (webmail84.yandex.ru [77.88.47.158])
	by forward15.mail.yandex.net (Yandex) with ESMTP id 40433C05C2
	for <netdev@vger.kernel.org>; Tue,  9 Mar 2010 20:21:35 +0300 (MSK)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by webmail84.yandex.ru (Yandex) with ESMTP id 086E737C00C
	for <netdev@vger.kernel.org>; Tue,  9 Mar 2010 20:21:34 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Eric

>  > Mar  9 10:08:55 bras-1 kernel:
>  > Mar  9 10:08:55 bras-1 kernel: Pid: 0, comm: swapper Not tainted (2.6.32 #3)
>  
>  Is it an unpatched kernel ?

Yes. Vanilla 2.6.32. We saw the same issue on at least 2.6.30.1 (as far as I know).

>  
>  Could you send us your .config ?
>  

Here it is: http://www.progtech.ru/~oleg/config.txt

>  gcc -v ?

Reading specs from /usr/lib/gcc/i486-slackware-linux/4.3.3/specs
Target: i486-slackware-linux
Configured with: ../gcc-4.3.3/configure --prefix=/usr --libdir=/usr/lib --enable-shared --enable-bootstrap --enable-languages=ada,c,c++,fortran,java,objc --enable-threads=posix --enable-checking=release --with-system-zlib --disable-libunwind-exceptions --enable-__cxa_atexit --enable-libssp --with-gnu-ld --verbose --with-arch=i486 --target=i486-slackware-linux --build=i486-slackware-linux --host=i486-slackware-linux
Thread model: posix
gcc version 4.3.3 (GCC)

-- 
wbr, Oleg.
