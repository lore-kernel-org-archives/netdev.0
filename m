From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v6 5/7] ARM: kirkwood: remove redundant DT board files
Date: Wed, 03 Jul 2013 13:31:47 +0200
Message-ID: <51D40BA3.6000603@gmail.com>
References: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com> <1372762824-12202-6-git-send-email-sebastian.hesselbarth@gmail.com> <87k3l8v9s1.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k3l8v9s1.fsf@natisbad.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/03/13 01:09, Arnaud Ebalard wrote:
> Hi Sebastian,
>
> Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> writes:
>
>> With DT support for mv643xx_eth board specific init for some boards now
>> is unneccessary. Remove those board files, Kconfig entries, and
>> corresponding entries in kirkwood_defconfig.
>
> Applying above your set an old quilt cleaning patch Jason asked at some
> point, it became empty except for arch/arm/mach_kirkwood/common.h in
> which some declarations were left behind. If this is correct, can you
> just merge the hunks below in your 5/7 in next round?
>
> AFAICT, only dnskw_init() remains, which matches the list of board-*.c
> files in arch/arm/mach_kirkwood/ (i.e. board-dt.c and board-dnskw.c).

While updating the patch with yours, I stumbled upon MACH_TS219_DT that
also remains because it includes tsx1x-common.c.

I cannot recall if Jason or Andrew said something about removing it..

Sebastian
