From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Tue, 20 Jan 2004 21:50:12 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401202150.12892.harisri@bigpond.com>
References: <200401152039.00182.harisri@bigpond.com> <200401192251.41323.harisri@bigpond.com> <20040120002422.A19029@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040120002422.A19029@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Francois,

On Tuesday 20 January 2004 10:24, Francois Romieu wrote:
> > The r8169-tc-index-overflow.patch does not (cleanly) apply on 2.6.1-bk2 +
> > netdev4.
>
> Can you verify that your kernel tree is fine or give an (sh-)history of
> the applied patches ?

cd /usr/local/src
tar xfj /media/cdrecorder/v2.6/linux-2.6.0.tar.bz2
cd linux-2.6.0
bunzip2 -c /media/cdrecorder/v2.6/patch-2.6.1.bz2 |patch -p1
bunzip2 -c ~/linux/patch-2.6.1-bk2.bz2 |patch -p1
bunzip2 -c ~/linux/2.6.1-bk1-netdev4.patch.bz2 |patch -p1
patch -p1 --dry-run < ~/linux/r8169/r8169-tx-index-overflow.patch
patching file drivers/net/r8169.c
Hunk #1 succeeded at 1341 (offset 364 lines).
Hunk #2 FAILED at 1351.
Hunk #3 succeeded at 1365 with fuzz 1 (offset 367 lines).
1 out of 3 hunks FAILED -- saving rejects to file drivers/net/r8169.c.rej

> I have just checked and the patch applies cleanly on kernel 2.6.1-bk2 +
> Jeff's 2.6.1-bk1-netdev4 as well as on kernel 2.6.1-bk4 + Jeff's
> 2.6.1-bk4-netdev1.

Interesting.

In this very thread you mentioned (in which you did not cc me BTW :-) that you 
welcomed AMD64-RTL8169 users, that gave me an idea. I tested this computer 
under 32 bit kernel (vanilla Fedora + 2.6.1-mm4) in which it survives my 
torture test (I have verified for no more than 5 minutes though, but then it 
does not survive for more than 5 secs under the 64 bit kernel).

(And BTW I do not like binary only kernel modules, and I do these bug 
reporting "for fun", and there is no fun in binary only modules. I have been 
reading lkml for long enough to understand that :-)

Thanks for help and suggestions so far, I appreciate them.

Hari
