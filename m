From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [2.6.29-rc2 regression] e100: netconsole not functional because
	of missing firmware
Date: Mon, 19 Jan 2009 10:30:01 -0800
Message-ID: <4807377b0901191030g27efac79rbd39501eb2eea4cb@mail.gmail.com>
References: <200901171908.28533.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.soutceforge.net,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrey Borzenkov <arvidjaar@mail.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752636AbZASSaZ@vger.kernel.org>
In-Reply-To: <200901171908.28533.arvidjaar@mail.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 17, 2009 at 8:08 AM, Andrey Borzenkov <arvidjaar@mail.ru> wrote:
> [    2.008509] e100: eth0: e100_request_firmware: Failed to load
> firmware "e100/d101m_ucode.bin": -22
> [    2.010461] netconsole: failed to open eth0
> [    2.010996] netconsole: cleaning up
>
> This has been working all the time without requiring any external
> firmware to be present. Why it suddenly refuses to work now?

to use netconsole you probably need to set config option
CONFIG_FIRMWARE_IN_KERNEL=y

Hm, I wonder if we couldn't have netconsole=y select
CONFIG_FIRMWARE_IN_KERNEL in Kconfig

the arguments as to why the firmware was split out of the drivers have
already been made on this list.  Not that I agree with them, but the
decision has been made and we're (network devs) going along with it.
