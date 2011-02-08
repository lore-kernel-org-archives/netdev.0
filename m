From: Jack Daniel <wanders.thirst@gmail.com>
Subject: usage setkey delete option for ipsec
Date: Tue, 8 Feb 2011 15:44:04 +0530
Message-ID: <AANLkTi=6--vQco+vh_RGCwUVkm0UzMZcSHj8oaUWC+Vc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:44297 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630Ab1BHKOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 05:14:06 -0500
Received: by iwn9 with SMTP id 9so5565074iwn.19
        for <netdev@vger.kernel.org>; Tue, 08 Feb 2011 02:14:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

My intention is to delete SADB entries one by one using the setkey
delete option.
I have the follwoing entry in my setkey.conf

delete fec2::1[55001] fec2:0:f675:803a::4[55002] esp 4101;

But when running $setkey -f setkey.conf
it throws scuh an error ...
line 1: syntax error at [[]
parse failed, line 1.

If I remove the port values [55001] and [55002] then setkey says
"The result of line 1: No such process."

My $setkey -D
output is shown below

setkey -D
fec2:0:888b:5e45::6 fec2::1
       esp mode=transport spi=4106(0x0000100a) reqid=0(0x00000000)
       A: hmac-sha1  41482053 4120636f 6e666967 75726174 696f6e21
       seq=0x00000000 replay=0 flags=0x00000000 state=mature
       created: Feb  7 15:33:45 2011   current: Feb  7 17:09:22 2011
       diff: 5737(s)   hard: 0(s)      soft: 0(s)
       last:                           hard: 0(s)      soft: 0(s)
       current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
       allocated: 0    hard: 0 soft: 0
       sadb_seq=7 pid=18112 refcnt=0
fec2:0:888b:5e44::5 fec2::1
       esp mode=transport spi=4104(0x00001008) reqid=0(0x00000000)
       A: hmac-sha1  41482053 4120636f 6e666967 75726174 696f6e21
       seq=0x00000000 replay=0 flags=0x00000000 state=mature
       created: Feb  7 15:33:45 2011   current: Feb  7 17:09:22 2011
       diff: 5737(s)   hard: 0(s)      soft: 0(s)
       last:                           hard: 0(s)      soft: 0(s)
       current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
       allocated: 0    hard: 0 soft: 0
       sadb_seq=6 pid=18112 refcnt=0
fec2:0:888b:5e43::4 fec2::1
       esp mode=transport spi=4102(0x00001006) reqid=0(0x00000000)
       A: hmac-sha1  41482053 4120636f 6e666967 75726174 696f6e21
       seq=0x00000000 replay=0 flags=0x00000000 state=mature
       created: Feb  7 15:33:45 2011   current: Feb  7 17:09:22 2011
       diff: 5737(s)   hard: 0(s)      soft: 0(s)
       last:                           hard: 0(s)      soft: 0(s)
       current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
       allocated: 0    hard: 0 soft: 0
       sadb_seq=5 pid=18112 refcnt=0
fec2:0:888b:5e42::3 fec2::1
       esp mode=transport spi=4100(0x00001004) reqid=0(0x00000000)
       A: hmac-sha1  41482053 4120636f 6e666967 75726174 696f6e21
       seq=0x00000000 replay=0 flags=0x00000000 state=mature
       created: Feb  7 15:33:45 2011   current: Feb  7 17:09:22 2011
       diff: 5737(s)   hard: 0(s)      soft: 0(s)
       last:                           hard: 0(s)      soft: 0(s)
       current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
       allocated: 0    hard: 0 soft: 0
       sadb_seq=4 pid=18112 refcnt=0
fec2::1 fec2:0:888b:5e42::3
       esp mode=transport spi=4099(0x00001003) reqid=0(0x00000000)
       A: hmac-sha1  41482053 4120636f 6e666967 75726174 696f6e21
       seq=0x00000000 replay=0 flags=0x00000000 state=mature
       created: Feb  7 15:33:45 2011   current: Feb  7 17:09:22 2011
       diff: 5737(s)   hard: 0(s)      soft: 0(s)
       last:                           hard: 0(s)      soft: 0(s)
       current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
       allocated: 0    hard: 0 soft: 0
       sadb_seq=3 pid=18112 refcnt=0
fec2::1 fec2:0:888b:5e43::4
       esp mode=transport spi=4101(0x00001005) reqid=0(0x00000000)
       A: hmac-sha1  41482053 4120636f 6e666967 75726174 696f6e21
       seq=0x00000000 replay=0 flags=0x00000000 state=mature
       created: Feb  7 15:33:45 2011   current: Feb  7 17:09:22 2011
       diff: 5737(s)   hard: 0(s)      soft: 0(s)
       last:                           hard: 0(s)      soft: 0(s)
       current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
       allocated: 0    hard: 0 soft: 0
       sadb_seq=2 pid=18112 refcnt=0
fec2::1 fec2:0:888b:5e44::5
       esp mode=transport spi=4103(0x00001007) reqid=0(0x00000000)
       A: hmac-sha1  41482053 4120636f 6e666967 75726174 696f6e21
       seq=0x00000000 replay=0 flags=0x00000000 state=mature
       created: Feb  7 15:33:45 2011   current: Feb  7 17:09:22 2011
       diff: 5737(s)   hard: 0(s)      soft: 0(s)
       last:                           hard: 0(s)      soft: 0(s)
       current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
       allocated: 0    hard: 0 soft: 0
       sadb_seq=1 pid=18112 refcnt=0
fec2::1 fec2:0:888b:5e45::6
       esp mode=transport spi=4105(0x00001009) reqid=0(0x00000000)
       A: hmac-sha1  41482053 4120636f 6e666967 75726174 696f6e21
       seq=0x00000000 replay=0 flags=0x00000000 state=mature
       created: Feb  7 15:33:45 2011   current: Feb  7 17:09:22 2011
       diff: 5737(s)   hard: 0(s)      soft: 0(s)
       last:                           hard: 0(s)      soft: 0(s)
       current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
       allocated: 0    hard: 0 soft: 0
       sadb_seq=0 pid=18112 refcnt=0


Could someone point out what I might be doing wrong or the right way
to pass the "delete" option an ipv6 address along with the port in
square brackets.

Thanks and regards,
Jack.
