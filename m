From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: [PATCH net-next] net: vxge: Add MODULE_FIRMWARE
Date: Mon, 16 Apr 2012 08:52:07 -0600
Message-ID: <4F8C3217.4030702@canonical.com>
References: <1334262882-96973-1-git-send-email-tim.gardner@canonical.com>  <1334498215.3209.4.camel@deadeye> <4F8C0EE1.7030901@canonical.com> <1334586550.3209.128.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jon Mason <jdmason@kudzu.us>,
	netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334586550.3209.128.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

On 04/16/2012 08:29 AM, Ben Hutchings wrote:
>> 
>> I guess I'm confused about use of the MODULE_FIRMWARE() macro. I 
>> thought it merely described the names of the firmware files that
>> were actually used by the driver and had no run-time impact.
>> Regardless of whether firmware files are used on every load, why
>> _not_ describe them to modinfo ?
> [...]
> 
> Ah, that's a good question.  Quoting my own interpretation from 
> <1257629601.15927.361.camel@localhost>:
> 
>> Drivers that must load 'firmware' into the devices they drive
>> should declare the names of the files they will request, using
>> the MODULE_FIRMWARE() macro.  This enables other tools to
>> discover these dependencies statically, and warn the user if
>> firmware files are missing.
> 
> In Debian we use this to decide which files need to be copied into
> an initramfs.  You use that too unless you've changed this feature
> of initramfs-tools.  We warn when building an initramfs and during
> a major kernel upgrade if it looks like a driver will be used and
> the corresponding firmware isn't installed.
> 

Yep, we've merged "initramfs-tools (0.99) unstable" into precise. I'll
assume it behaves as described. The Ubuntu server installer will
certainly annoy you if firmware is missing. Its likely the LiveCD will
as well.

> I also have an (unfinished) patch that will use this information
> for CONFIG_FIRMWARE_IN_KERNEL.
> 
> In this case the firmware files are used to upgrade old flash, but
> since the vendor has closed down there aren't going to be any
> further updates. So the likelihood of the files actually being
> needed by the driver is very small.
> 
> Ben.
> 

I didn't realize the vendor is defunct, so I suddenly don't care as much.

rtg
- -- 
Tim Gardner tim.gardner@canonical.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJPjDIXAAoJED12yEX6FEfKRE4P/j7zqPOeom4wwocrn4zQrU/6
BW5BTUpea9pnC7dgIp/Vl/HgO+5WrdApBrcONpfJeHE+1bBM1gx6NANLu2qPx3BG
EqMUI+I7bAbwFqUQnDs1wgqfat5CKTGfmf8lwjTzbmRVMlPRMfCGZWlfSL/Pi9Tn
5R8M4TxbspOkI0+iRmcjlOiRVAYuTglaiQD9r0cqyRQeJ+jQ5RK/uwCNyTKHh3eB
LmeXj7RU/gbUiXZkqh6HEtT9QqhOL2BYHboVjHnKGcdvLylqaLNiwcWKLOrQ4bxy
q3GuLtEmAb7fV5stONhyoqrDBfvWGNtbOSmqW4yXIeKOT3S4/UOs+LrrIXItgLgD
qpBW9xBNjT+K+DkTh8iTpCF39igyMG+PvPJ3bjxEznPZoYU5TLJLPrw6YDUnfe54
lFUMdnAVHZmgdF9uUrakNacwPXkdTd3t4F+Y+sPLxaHYyOC/+hrXnkj9KLxlVjYr
RP82iHhINcNgEl5Rqj98Kp0kw8vsVBuDm5i5LvaRLlah7PNWJ/tSbFXwG+qC0VZK
BkVSatVyLgWDOJAN4NYgPME9/IAV+Mmlu7ZOIN/8oyRiMaK4HPsDDSLYhwthmXN3
r9ViAJTdGCBf+FTvLS8H3YXbueFuLNoH0nfV4oPB77jrYWesEPEqJlKPqefJAVAG
NZshSCqSm2x4C+2UXuhp
=BYdE
-----END PGP SIGNATURE-----
