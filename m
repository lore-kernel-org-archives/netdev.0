From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] MAINTAINERS: Remove myself from PA Semi entries
Date: Wed, 14 Sep 2016 18:57:55 +1000
Message-ID: <87k2eeoo30.fsf@concordia.ellerman.id.au>
References: <1473803318-25197-1-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-i2c@vger.kernel.org,
        davem@davemloft.net, jdelvare@suse.com,
        Olof Johansson <olof@lixom.net>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:50998 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751621AbcINI55 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 04:57:57 -0400
In-Reply-To: <1473803318-25197-1-git-send-email-olof@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson <olof@lixom.net> writes:

> The platform is old, very few users and I lack bandwidth to keep after
> it these days.
>
> Mark the base platform as well as the drivers as orphans, patches have
> been flowing through the fallback maintainers for a while already.

Sorry to see you go, but thanks for keeping an eye on it as long as you
did!

> Jean, Dave,
>
> I was hoping to have Michael merge this since the bulk of the platform is under him,
> cc:ing you mostly to be aware that I am orphaning a driver in your subsystems.

I'll merge it unless I hear otherwise from Dave.

Should we go the whole hog and just do as below? I think most folks use
get_maintainers.pl these days, so this should have basically the same
effect. Happy to go with your original version though if you prefer.

cheers


diff --git a/MAINTAINERS b/MAINTAINERS
index 0bbe4b105c34..8ca1c25d870d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7049,6 +7049,7 @@ N:	powermac
 N:	powernv
 N:	[^a-z0-9]ps3
 N:	pseries
+N:	pasemi
 
 LINUX FOR POWER MACINTOSH
 M:	Benjamin Herrenschmidt <benh@kernel.crashing.org>
@@ -7098,14 +7099,6 @@ S:	Maintained
 F:	arch/powerpc/platforms/83xx/
 F:	arch/powerpc/platforms/85xx/
 
-LINUX FOR POWERPC PA SEMI PWRFICIENT
-M:	Olof Johansson <olof@lixom.net>
-L:	linuxppc-dev@lists.ozlabs.org
-S:	Maintained
-F:	arch/powerpc/platforms/pasemi/
-F:	drivers/*/*pasemi*
-F:	drivers/*/*/*pasemi*
-
 LINUX SECURITY MODULE (LSM) FRAMEWORK
 M:	Chris Wright <chrisw@sous-sol.org>
 L:	linux-security-module@vger.kernel.org
@@ -8773,18 +8766,6 @@ W:	http://wireless.kernel.org/en/users/Drivers/p54
 S:	Maintained
 F:	drivers/net/wireless/intersil/p54/
 
-PA SEMI ETHERNET DRIVER
-M:	Olof Johansson <olof@lixom.net>
-L:	netdev@vger.kernel.org
-S:	Maintained
-F:	drivers/net/ethernet/pasemi/*
-
-PA SEMI SMBUS DRIVER
-M:	Olof Johansson <olof@lixom.net>
-L:	linux-i2c@vger.kernel.org
-S:	Maintained
-F:	drivers/i2c/busses/i2c-pasemi.c
-
 PADATA PARALLEL EXECUTION MECHANISM
 M:	Steffen Klassert <steffen.klassert@secunet.com>
 L:	linux-crypto@vger.kernel.org
