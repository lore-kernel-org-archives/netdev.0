From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Wed, 21 Jan 2004 21:15:44 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401212115.45027.harisri@bigpond.com>
References: <200401152039.00182.harisri@bigpond.com> <200401202150.12892.harisri@bigpond.com> <20040120215230.A8935@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040120215230.A8935@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Francois,

On Wednesday 21 January 2004 07:52, Francois Romieu wrote:
> [snip]
> $ cat>foo<<EOD
> tar jxf linux-2.6.0.tar.bz2
> bunzip2 -c patch-2.6.1.bz2 | patch -p1 -d linux-2.6.0
> bunzip2 -c patch-2.6.1-bk2.bz2 | patch -p1 -d linux-2.6.0
> bunzip2 -c 2.6.1-bk1-netdev4.patch.bz2 | patch -p1 -d linux-2.6.0
> wget
> http://www.fr.zoreil.com/people/francois/misc/r8169-tx-index-overflow.patch
> EOD
> $ sh foo
> [...]
> $ patch -p1 -d linux-2.6.0 < r8169-tx-index-overflow.patch
> patching file drivers/net/r8169.c
>
> Okay...
>
> $ md5sum r8169-tx-index-overflow.patch
> 99b2f5886d6bf1d4df0f7553bb5bef57  r8169-tx-index-overflow.patch
>
> [...]

Must be my mistake. Thanks for verifying things.

> I did :o)
>
>    ----- The following addresses had permanent fatal errors -----
> <harisri@bigpond.com>
>     (reason: 554 recipient <harisri@bigpond.com> exceeds mailbox storage
> quota)

:-) I apologies for that. God save me from the Spammers!

> > under 32 bit kernel (vanilla Fedora + 2.6.1-mm4) in which it survives my
> > torture test (I have verified for no more than 5 minutes though, but then
> > it does not survive for more than 5 secs under the 64 bit kernel).
>
> Point taken.

I have a good news: I checked out things as usual under vanilla 
linux-2.6.2-rc1, and to my surprise Kernel does not hang anymore :-). 
(although Tx counter not incrementing is altogether another problem).

If you want me to I can test your r8169-tc-index-overflow.patch.

Thanks
Hari 
