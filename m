From: "John Stoffel" <john@stoffel.org>
Subject: 2.6.26-rc5: CFI: Found no ck804xrom @ffc00000 device at
   location zero
Date: Thu, 12 Jun 2008 14:34:36 -0400
Message-ID: <18513.27708.452410.527696@stoffel.org>
References: <20080612182308.GA1091@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: i2c@lm-sensors.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mycroft.westnet.com ([216.187.52.7]:54068 "EHLO
	Mycroft.westnet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbYFLSiy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 14:38:54 -0400
In-Reply-To: <20080612182308.GA1091@ldl.fc.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I'm running a AMD X2 box with 4gb of RAM, Ubuntu 8.04 x86_64.  I just
rebooted the system and I notice the following repeated messages
(errors? warnings?) in my dmesg output.  I think this is from my
nForce ethernet chips, but I'm not sure.

[   13.268005] ck804xrom ck804xrom_init_one(): Unable to register resource 0x00000000ff000000-0x00000000ffffffff - kernel bug?
[   13.336752] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[   13.336786] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[   13.376771] CFI: Found no ck804xrom @ffc00000 device at location zero
[   13.398810] JEDEC: Found no ck804xrom @ffc00000 device at location zero
[   13.398822] CFI: Found no ck804xrom @ffc00000 device at location zero
[   13.398883] JEDEC: Found no ck804xrom @ffc00000 device at location zero
[   13.398889] CFI: Found no ck804xrom @ffc00000 device at location zero
[   13.398928] JEDEC: Found no ck804xrom @ffc00000 device at location zero
[   13.398934] CFI: Found no ck804xrom @ffc10000 device at location zero
[   13.398971] JEDEC: Found no ck804xrom @ffc10000 device at location zero
[   13.398980] CFI: Found no ck804xrom @ffc10000 device at location zero
[   13.399042] JEDEC: Found no ck804xrom @ffc10000 device at location zero
[   13.399048] CFI: Found no ck804xrom @ffc10000 device at location zero
[   13.399579] JEDEC: Found no ck804xrom @ffc10000 device at location zero
[   13.399579] CFI: Found no ck804xrom @ffc20000 device at location zero
[   13.399582] JEDEC: Found no ck804xrom @ffc20000 device at location zero
[   13.399591] CFI: Found no ck804xrom @ffc20000 device at location zero
[   13.399652] JEDEC: Found no ck804xrom @ffc20000 device at location zero
[   13.399658] CFI: Found no ck804xrom @ffc20000 device at location zero
[   13.399696] JEDEC: Found no ck804xrom @ffc20000 device at location zero
[   13.399702] CFI: Found no ck804xrom @ffc30000 device at location zero
[   13.399739] JEDEC: Found no ck804xrom @ffc30000 device at location zero
[   13.399748] CFI: Found no ck804xrom @ffc30000 device at location zero
[   13.399809] JEDEC: Found no ck804xrom @ffc30000 device at location zero
[   13.399815] CFI: Found no ck804xrom @ffc30000 device at location zero
[   13.399853] JEDEC: Found no ck804xrom @ffc30000 device at location zero
[   13.399859] CFI: Found no ck804xrom @ffc40000 device at location zero
[   13.399896] JEDEC: Found no ck804xrom @ffc40000 device at location zero
[   13.399905] CFI: Found no ck804xrom @ffc40000 device at location zero
[   13.400587] JEDEC: Found no ck804xrom @ffc40000 device at location zero
[   13.400593] CFI: Found no ck804xrom @ffc40000 device at location zero
[   13.400631] JEDEC: Found no ck804xrom @ffc40000 device at location zero
[   13.400637] CFI: Found no ck804xrom @ffc50000 device at location zero
[   13.400674] JEDEC: Found no ck804xrom @ffc50000 device at location zero
[   13.400683] CFI: Found no ck804xrom @ffc50000 device at location zero
[   13.400744] JEDEC: Found no ck804xrom @ffc50000 device at location zero
[   13.400750] CFI: Found no ck804xrom @ffc50000 device at location zero
[   13.400788] JEDEC: Found no ck804xrom @ffc50000 device at location zero
[   13.400795] CFI: Found no ck804xrom @ffc60000 device at location zero
[   13.400831] JEDEC: Found no ck804xrom @ffc60000 device at location zero
[   13.400840] CFI: Found no ck804xrom @ffc60000 device at location zero
[   13.400902] JEDEC: Found no ck804xrom @ffc60000 device at location zero
[   13.400908] CFI: Found no ck804xrom @ffc60000 device at location zero
[   13.401577] JEDEC: Found no ck804xrom @ffc60000 device at location zero
[   13.401577] CFI: Found no ck804xrom @ffc70000 device at location zero
.
.
.
.
.
.
[   13.420781] JEDEC: Found no ck804xrom @fff60000 device at location zero
[   13.420789] CFI: Found no ck804xrom @fff60000 device at location zero
[   13.420851] JEDEC: Found no ck804xrom @fff60000 device at location zero
[   13.420857] CFI: Found no ck804xrom @fff60000 device at location zero
[   13.420895] JEDEC: Found no ck804xrom @fff60000 device at location zero
[   13.420901] CFI: Found no ck804xrom @fff70000 device at location zero
[   13.421576] JEDEC: Found no ck804xrom @fff70000 device at location zero
[   13.421576] CFI: Found no ck804xrom @fff70000 device at location zero
[   13.421626] JEDEC: Found no ck804xrom @fff70000 device at location zero
[   13.421632] CFI: Found no ck804xrom @fff70000 device at location zero
[   13.421670] JEDEC: Found no ck804xrom @fff70000 device at location zero
[   13.421698] CFI: Found no ck804xrom @fff80000 device at location zero
[   13.421881] JEDEC: Found no ck804xrom @fff80000 device at location zero
[   13.421908] CFI: Found no ck804xrom @fff80000 device at location zero
[   13.422716] JEDEC: Found no ck804xrom @fff80000 device at location zero
[   13.422728] CFI: Found no ck804xrom @fff80000 device at location zero
[   13.422752] Found: PMC Pm49FL004
[   13.422775] ck804xrom @fff80000: Found 1 x8 devices at 0x0 in 8-bit bank
[   13.486876] number of JEDEC chips: 1
[   13.486897] cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenness.




These messages seem really damn noisy, esp since it does find a JEDEC chip eventually.  I'll try and see about bisecting this later on if I get a chance.

John
