From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Tue, 20 Jan 2004 21:52:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040120215230.A8935@electric-eye.fr.zoreil.com>
References: <200401152039.00182.harisri@bigpond.com> <200401192251.41323.harisri@bigpond.com> <20040120002422.A19029@electric-eye.fr.zoreil.com> <200401202150.12892.harisri@bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <harisri@bigpond.com>
Content-Disposition: inline
In-Reply-To: <200401202150.12892.harisri@bigpond.com>; from harisri@bigpond.com on Tue, Jan 20, 2004 at 09:50:12PM +1100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <harisri@bigpond.com> :
> On Tuesday 20 January 2004 10:24, Francois Romieu wrote:
[...]
> cd /usr/local/src
> tar xfj /media/cdrecorder/v2.6/linux-2.6.0.tar.bz2
> cd linux-2.6.0
> bunzip2 -c /media/cdrecorder/v2.6/patch-2.6.1.bz2 |patch -p1
> bunzip2 -c ~/linux/patch-2.6.1-bk2.bz2 |patch -p1
> bunzip2 -c ~/linux/2.6.1-bk1-netdev4.patch.bz2 |patch -p1
> patch -p1 --dry-run < ~/linux/r8169/r8169-tx-index-overflow.patch
> patching file drivers/net/r8169.c
> Hunk #1 succeeded at 1341 (offset 364 lines).
> Hunk #2 FAILED at 1351.
> Hunk #3 succeeded at 1365 with fuzz 1 (offset 367 lines).
> 1 out of 3 hunks FAILED -- saving rejects to file drivers/net/r8169.c.rej

$ cat>foo<<EOD
tar jxf linux-2.6.0.tar.bz2 
bunzip2 -c patch-2.6.1.bz2 | patch -p1 -d linux-2.6.0
bunzip2 -c patch-2.6.1-bk2.bz2 | patch -p1 -d linux-2.6.0
bunzip2 -c 2.6.1-bk1-netdev4.patch.bz2 | patch -p1 -d linux-2.6.0
wget http://www.fr.zoreil.com/people/francois/misc/r8169-tx-index-overflow.patch
EOD
$ sh foo
[...]
$ patch -p1 -d linux-2.6.0 < r8169-tx-index-overflow.patch 
patching file drivers/net/r8169.c

Okay...

$ md5sum r8169-tx-index-overflow.patch 
99b2f5886d6bf1d4df0f7553bb5bef57  r8169-tx-index-overflow.patch

[...]
> In this very thread you mentioned (in which you did not cc me BTW :-) that 
> welcomed AMD64-RTL8169 users, that gave me an idea. I tested this computer 

I did :o)

   ----- The following addresses had permanent fatal errors -----
<harisri@bigpond.com>
    (reason: 554 recipient <harisri@bigpond.com> exceeds mailbox storage quota)

> under 32 bit kernel (vanilla Fedora + 2.6.1-mm4) in which it survives my 
> torture test (I have verified for no more than 5 minutes though, but then it 
> does not survive for more than 5 secs under the 64 bit kernel).

Point taken.

--
Ueimor
