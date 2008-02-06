From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86_32: fix regression caused by trim ram
	according to	mtrr on system with 4G more RAM
Date: Wed, 6 Feb 2008 10:51:07 +0100
Message-ID: <20080206095107.GA30596@elte.hu>
References: <47A89A77.1050608@openvz.org>
	<200802060119.25278.yinghai.lu@sun.com>
	<47A97E28.1010400@openvz.org>
	<200802060149.26083.yinghai.lu@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	Denis Lunev <den@openvz.org>, Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Justin Piszcz <jpiszcz@lucidpixels.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <200802060149.26083.yinghai.lu@sun.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* Yinghai Lu <Yinghai.Lu@Sun.COM> wrote:

> [PATCH] x86_32: fix regression caused by trim ram according to mtrr on sy=
stem with 4G more RAM
> =

> Pravel report:
> "
> The commit
> =

> =A0=A0=A0=A0=A0=A0=A0=A0093af8d7f0ba3c6be1485973508584ef081e9f93
> =A0=A0=A0=A0=A0=A0=A0=A0x86_32: trim memory by updating e820
> =

> broke my e1000 card: on loading driver says that
> =

> =A0=A0=A0=A0=A0=A0=A0=A0e1000: probe of 0000:04:03.0 failed with error -5
> =

> and the interface doesn't appear.
> "
> =

> on 32 bit kernel, base will overflow when try to do PAGE_SHIFT. and =

> highest_addr will always less 4G.
> =

> so use pfn instead of address to avoid overflow when more than 4g
>  ram installed on 32bit kernel
> Many thanks for Pavel Emelyanov to report and test it.

thanks guys, applied.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
