From: Solmaz Mustafa <mustafa.solmaz@uk.thalesgroup.com>
Subject: Atomic.h for PPC
Date: Thu, 9 Oct 2003 15:28:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41DD7618430DD411870400D0B746EDED0DC82C4F@mail.tms-ltd.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I am trying to develop a program on PowerPC and as trying to use LOKI's
smart pointers I had some problems of compilation. 
Loki's headers use atomic_inc_and_test() and atomic_dec_and_test() atomic
operations for multi-threaded purpose. Those methods are available in many
of Linux Kernel APIs but in the one for Power PCs. Almost all
/usr/include/asm/atomic.h files have those methods well defined but on Power
PCs. 

My atomic.h is 11th version and that it has atomic_inc_return() method which
I suppose will be used later as atomic_inc_and_test() method.
Would you please show me a way to sort out this problem? I can write my own
methods using the current atomic.h but I just do not know how to implement
it in a safe way. 

Best regards,

Mustafa SOLMAZ

Thales Underwater Systems
United Kingdom
+441963 372 152
This email and any attachments are confidential to the intended recipient
and may also be privileged. If you are not the intended recipient please
delete it from your system and notify Thales Underwater Systems on +44 1963
370 551. You should not copy it or use it for any purpose nor disclose or
distribute its contents to any other person.
