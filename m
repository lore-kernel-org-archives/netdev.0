From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: Re: forcedeth on Asus-Board
Date: Mon, 19 Jan 2004 01:32:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400B258D.4010301@gmx.net>
References: <40096CBE.6030809@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Edgar Dombrowski <dj3pu@t-online.de>
In-Reply-To: <40096CBE.6030809@t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Edgar Dombrowski wrote:
> Dear Tuxers.
> 
> Referring to an information published recently in a German Linux
> Magazine, I downloaded today the "forcedeth.o" module.
> 
> However I got a failure report as attached.

[unresolved symbols due to version mismatch]
> 
> I am using an ASUS Board A7N8X with SUSE Linux Version 9.0, Kernel
> version 2.4.22.

You are using 2.4.21-99.

> 
> Can You help?

Yes. Please upgrade to k_athlon-2.4.21-166 because that has many security
fixes you'll need. Simply issue an online update or download
ftp://ftp.leo.org:/pub/suse/i386/update/9.0/rpm/i586/k_athlon-2.4.21-166.i586.rpm
and install it with
yast -i k_athlon-2.4.21-166.i586.rpm
Then download the latest (dated 3004-01-19) forcedeth.o from
http://www.hailfinger.org/carldani/linux/patches/forcedeth/ and copy it to
/lib/modules/2.4.21-166-athlon/kernel/drivers/net/
and run lilo if needed (you probably use grub so this won't apply).
Now reboot and everything should be fine.

HTH,
Carl-Daniel
-- 
http://www.hailfinger.org/
