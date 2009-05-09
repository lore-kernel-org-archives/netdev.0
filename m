From: Panadero Pizza <panadero_pizza@yahoo.es>
Subject: Putting for discussion "__qdisc_run" bug - strange application-dependant error
Date: Sat, 9 May 2009 19:55:04 +0000 (GMT)
Message-ID: <657221.87331.qm@web28608.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web28608.mail.ukl.yahoo.com ([87.248.110.217]:37256 "HELO
	web28608.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753195AbZEITzF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 15:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello netdev group,

I would like to put for discussion, if a bug in the __qdsic_run function could explain the problem I have described in my post "Kernel networking problem (>=2.6.24.7)" two days ago.

"__qdisc_run" is the last common function in the kernel traces I receive for the kernels:

2.6.24.7
2.6.27.12

with a multi-threaded software, using fputc, putc, puts - calls, mixed with fflush()-calls on a remote file, opened on a cifs-handle. (Errors occur extremely seldom, although the software is running for hours - day after day)

I don't receive the error with other standard software (e.g. "dd"), writing to a file on the same cifs-handle/session and more interesting:
The error does not occur with the afore-mentioned multi-threaded program (or any other software), using a

2.6.16.62

kernel.

I have found that from 2.6.24.x on, the __qdisc_run function has been made preemptible and this feature has been enabled for the realization of the afore-said 2.6.24.7 and 2.6.27.12 kernels.

Though 2.6.16.62 solves my problem, I am offering participation in finding a solution for this (which should be fixed, if it is a kernel bug).

Best regards,
David


      
