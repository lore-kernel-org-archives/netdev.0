From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: Re: forcedeth 0.15: 08 Nov 2003 for kernel 2.4 just ping and DHCP
 traffic
Date: Sun, 16 Nov 2003 23:12:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB7F65C.3010007@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Joerg Esser <Jackfritt@boh.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Joerg Esser wrote:
> I've tried the above version on my ASUS A7N8X-VM Board because with the
> nvnet driver I just could ping other Computers and the other just
> could refresh their IP over DHCP(I?ve installed it on the Computer with
> the ASUS Board). Everything else like Webbrowsing ,FTP, etc didn?t
> work.

Looking at the debug output you provided, it seems your BIOS doesn't set
the MAC address correctly, but uses 01:23:45:67:89:ab instead.

> Now I tried your driver and I get the same results but with a lot more 
> of debug output.

Could you boot into MS-Windows and try to find out the MAC address from
there, then set this MAC address under Linux with ifconfig, using the
forcedeth driver since nvnet can't handle setting the MAC address manually.

Oh, and the output of
lspci -vvvxxx
as root would probably give an additional clue what happens/ where the MAC
address is stored.


Carl-Daniel
