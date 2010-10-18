From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [MeeGo-Dev] can: How to set bitrate
Date: Mon, 18 Oct 2010 13:05:10 +0200
Message-ID: <4CBC29E6.3070601@grandegger.com>
References: <000b01cb6eb3$1afcfd60$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Foster, Margie" <margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ML linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, "Wang,
	Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Ewe, Kok Howg" <kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel OTC <joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomoya MORINAGA <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, "Wang, Qi" <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <000b01cb6eb3$1afcfd60$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/18/2010 12:56 PM, Masayuki Ohtake wrote:
> I want to test our Socket CAN driver(for Topcliff) on Meego1.0.
> 
> For setting bitrate, I tried to install "iproute2". But the build failed.
> 
> ================================================
> [root@localhost iproute2-2.6.33]# make
> sh configure
> TC schedulers
>  ATM no
>  IPT using iptables
> make[1]: Entering directory `/root/iproute2-2.6.33/lib'
> 
> <omission>
> 
> ude  -o arpd arpd.c ../lib/libnetlink.a ../lib/libutil.a -ldb -lpthread
> arpd.c:19:20: error: db_185.h: No such file or directory
> arpd.c:42: error: expected '=', ',', ';', 'asm' or '__attribute__' before '*' token
> arpd.c: In function 'do_one_request':
> arpd.c:304: error: 'DBT' undeclared (first use in this function)
> arpd.c:304: error: (Each undeclared identifier is reported only once
> arpd.c:304: error: for each function it appears in.)
> arpd.c:304: error: expected ';' before 'dbkey'
> arpd.c:308: error: 'dbase' undeclared (first use in this function)
> arpd.c:338: error: 'dbkey' undeclared (first use in this function)
> arpd.c:341: error: 'dbdat' undeclared (first use in this function)
> arpd.c: In function 'get_arp_pkt':
> arpd.c:485: error: 'DBT' undeclared (first use in this function)
> arpd.c:485: error: expected ';' before 'dbkey'
> arpd.c:517: error: 'dbkey' undeclared (first use in this function)
> arpd.c:520: error: 'dbase' undeclared (first use in this function)
> arpd.c:520: error: 'dbdat' undeclared (first use in this function)
> arpd.c: In function 'main':
> arpd.c:670: error: 'dbase' undeclared (first use in this function)
> arpd.c:670: warning: implicit declaration of function 'dbopen'
> arpd.c:670: error: 'DB_HASH' undeclared (first use in this function)
> arpd.c:680: error: 'DBT' undeclared (first use in this function)
> arpd.c:680: error: expected ';' before 'dbkey'
> arpd.c:682: error: 'dbkey' undeclared (first use in this function)
> arpd.c:712: error: 'dbdat' undeclared (first use in this function)
> arpd.c:728: error: expected ';' before 'dbkey'
> arpd.c:730: error: 'R_NEXT' undeclared (first use in this function)
> make[1]: *** [arpd] Error 1
> make[1]: Leaving directory `/root/iproute2/misc'
> make: *** [all] Error 2
> [root@localhost iproute2]#
> ================================================

On my system I get:

~$ rpm -qf /usr/include/db_185.h
db4-devel-4.7.25-13.fc12.i686

Which means you need db4 devel to fully build iproute2.

> Do you know how to set bitrate on Meego?

ip from iproute2 is the right tool.

Wolfgang.
