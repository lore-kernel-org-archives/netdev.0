From: Craig <craig@haquarter.de>
Subject: Re: [Bugme-new] [Bug 16383] New: Regression with e1000e from 2.6.34.1
 to 2.6.35-rc5
Date: Thu, 22 Jul 2010 02:06:44 +0200
Message-ID: <4C478B94.1050904@haquarter.de>
References: <bug-16383-10286@https.bugzilla.kernel.org/> <20100721134843.f8b5b217.akpm@linux-foundation.org> <EA929A9653AAE14F841771FB1DE5A1365FFE8449AA@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070108030009070806070409"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:9607 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759081Ab0GVAF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 20:05:29 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FFE8449AA@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070108030009070806070409
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,

> On what HW is this issue seen? Please provide the output of:
Hardware (it was already on bugzilla as pointed out by Andrew): Lenovo
ThinkPad X201, model 3626W16 (i5)

> lspci -vvv
> ethtool -e 
> ethtool -S
see attached files

> kernel config.
https://bugzilla.kernel.org/attachment.cgi?id=27094

Best regards,

Stefan Behte

--------------070108030009070806070409
Content-Type: text/plain;
 name="ethtool-e"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ethtool-e"

Offset		Values
------		------
0x0000		5c ff 35 02 2d a9 00 08 ff ff c1 00 ff ff ff ff 
0x0010		02 a0 ff ff c3 10 53 21 aa 17 ea 10 00 00 00 00 
0x0020		02 07 00 00 00 00 05 a5 28 00 00 18 00 00 00 0c 
0x0030		64 2a 40 0b 43 08 13 00 ea 10 ad ba ea 10 eb 10 
0x0040		ad ba ad ba ad ba ad ba 00 80 90 80 00 4e 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 ff ff 
0x0060		00 01 00 40 33 13 07 40 ff ff ff ff ff ff ff ff 
0x0070		ff ff ff ff ff ff ff ff ff ff 00 01 ff ff 8b 42 
0x0080		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0090		00 00 00 00 00 00 ff ff ff ff ff ff ff ff ff ff 
0x00a0		23 88 30 00 18 00 31 00 24 88 30 00 16 00 31 00 
0x00b0		25 88 30 00 1c 00 31 00 8c 88 30 00 07 00 31 00 
0x00c0		8d 88 30 00 07 00 31 00 8e 88 30 00 07 00 31 00 
0x00d0		27 88 30 00 01 00 31 00 35 88 30 00 01 00 31 00 
0x00e0		34 88 30 00 01 00 31 00 33 88 30 00 02 00 31 00 
0x00f0		40 60 1f 00 04 d0 11 00 07 01 12 00 00 00 1f 00 
0x0100		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0110		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0120		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0130		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0140		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0150		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0160		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0170		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0180		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0190		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0200		69 53 84 03 01 00 00 00 00 00 00 00 00 00 00 00 
0x0210		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0220		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0230		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0240		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0250		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0260		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0270		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0280		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0290		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x02a0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x02b0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x02c0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x02d0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x02e0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x02f0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0300		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0310		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0320		00 00 00 00 00 00 00 00 03 3d 00 00 00 00 00 00 
0x0330		00 00 00 00 00 00 00 00 00 00 00 00 bc 0c 00 00 
0x0340		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0350		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0360		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0370		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0380		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0390		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x03a0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x03b0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x03c0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x03d0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x03e0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x03f0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0400		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0410		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0420		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0430		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0440		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0450		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0460		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0470		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0480		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0490		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x04a0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x04b0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x04c0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x04d0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x04e0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x04f0		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0500		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0510		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0520		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0530		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0540		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0550		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0560		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0570		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0580		00 00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff 
0x0590		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0600		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0610		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0620		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0630		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0640		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0650		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0660		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0670		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0680		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0690		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0700		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0710		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0720		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0730		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0740		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0750		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0760		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0770		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0780		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0790		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0800		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0810		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0820		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0830		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0840		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0850		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0860		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0870		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0880		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0890		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0900		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0910		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0920		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0930		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0940		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0950		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0960		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0970		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0980		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0990		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0aa0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ab0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ac0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ad0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ae0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0af0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ba0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0be0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bf0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ca0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ce0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cf0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0da0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0db0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0dc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0dd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0de0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0df0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ea0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0eb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ec0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ed0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ee0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ef0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fa0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fe0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ff0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 

--------------070108030009070806070409
Content-Type: text/plain;
 name="ethtool-S"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ethtool-S"

NIC statistics:
     rx_packets: 152716
     tx_packets: 42897
     rx_bytes: 218463656
     tx_bytes: 3179209
     rx_broadcast: 16
     tx_broadcast: 21
     rx_multicast: 290
     tx_multicast: 0
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 0
     multicast: 290
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     tx_timeout_count: 0
     tx_restart_queue: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 5
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 218463656
     rx_csum_offload_good: 152393
     rx_csum_offload_errors: 0
     rx_header_split: 0
     alloc_rx_buff_failed: 0
     tx_smbus: 0
     rx_smbus: 4
     dropped_smbus: 0
     rx_dma_failed: 0
     tx_dma_failed: 0

--------------070108030009070806070409
Content-Type: text/plain;
 name="lspci-vvv"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="lspci-vvv"

00:00.0 Host bridge: Intel Corporation Core Processor DRAM Controller (rev 02)
	Subsystem: Lenovo Device 2193
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>
	Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation Core Processor Integrated Graphics Controller (rev 02) (prog-if 00 [VGA controller])
	Subsystem: Lenovo Device 215a
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f2000000 (64-bit, non-prefetchable) [size=4M]
	Region 2: Memory at d0000000 (64-bit, prefetchable) [size=256M]
	Region 4: I/O ports at 1800 [size=8]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a4] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: i915

00:16.0 Communication controller: Intel Corporation 5 Series/3400 Series Chipset HECI Controller (rev 06)
	Subsystem: Lenovo Device 215f
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f2727800 (64-bit, non-prefetchable) [size=16]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [8c] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000

00:19.0 Ethernet controller: Intel Corporation 82577LM Gigabit Network Connection (rev 06)
	Subsystem: Lenovo Device 2153
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 20
	Region 0: Memory at f2500000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f2525000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at 1820 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [e0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: e1000e
	Kernel modules: e1000e

00:1a.0 USB Controller: Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller (rev 06) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 2163
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 23
	Region 0: Memory at f2728000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci_hcd
	Kernel modules: ehci-hcd

00:1b.0 Audio device: Intel Corporation 5 Series/3400 Series Chipset High Definition Audio (rev 06)
	Subsystem: Lenovo Device 215e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at f2520000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [130] Root Complex Link <?>
	Kernel driver in use: HDA Intel

00:1c.0 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 1 (rev 06) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=0d, subordinate=0d, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #  0, PowerLimit 10.000000; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [90] Subsystem: Lenovo Device 2164
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport

00:1c.3 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 4 (rev 06) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=05, subordinate=0c, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: f0000000-f1ffffff
	Prefetchable memory behind bridge: 00000000f2800000-00000000f28fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  3, PowerLimit 10.000000; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [90] Subsystem: Lenovo Device 2164
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport

00:1c.4 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 5 (rev 06) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: f2400000-f24fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #5, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #  4, PowerLimit 10.000000; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [90] Subsystem: Lenovo Device 2164
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport

00:1d.0 USB Controller: Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller (rev 06) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 2163
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 19
	Region 0: Memory at f2728400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci_hcd
	Kernel modules: ehci-hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev a6) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Lenovo Device 2165

00:1f.0 ISA bridge: Intel Corporation Mobile 5 Series Chipset LPC Interface Controller (rev 06)
	Subsystem: Lenovo Device 2166
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>

00:1f.2 SATA controller: Intel Corporation 5 Series/3400 Series Chipset 6 port SATA AHCI Controller (rev 06) (prog-if 01 [AHCI 1.0])
	Subsystem: Lenovo Device 2168
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 16
	Region 0: I/O ports at 1860 [size=8]
	Region 1: I/O ports at 1814 [size=4]
	Region 2: I/O ports at 1818 [size=8]
	Region 3: I/O ports at 1810 [size=4]
	Region 4: I/O ports at 1840 [size=32]
	Region 5: Memory at f2727000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [70] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] SATA HBA <?>
	Capabilities: [b0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation 5 Series/3400 Series Chipset SMBus Controller (rev 06)
	Subsystem: Lenovo Device 2167
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f2728800 (64-bit, non-prefetchable) [size=256]
	Region 4: I/O ports at 1880 [size=32]

00:1f.6 Signal processing controller: Intel Corporation 5 Series/3400 Series Chipset Thermal Subsystem (rev 06)
	Subsystem: Lenovo Device 2190
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin D routed to IRQ 11
	Region 0: Memory at f2526000 (64-bit, non-prefetchable) [size=4K]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000

02:00.0 Network controller: Intel Corporation Centrino Ultimate-N 6300 (rev 35)
	Subsystem: Intel Corporation Centrino Ultimate-N 6300 3x3 AGN
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f2400000 (64-bit, non-prefetchable) [size=8K]
	Capabilities: [c8] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <32us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [140] Device Serial Number 00-24-d7-ff-ff-0a-45-68
	Kernel driver in use: iwlagn

ff:00.0 Host bridge: Intel Corporation Core Processor QuickPath Architecture Generic Non-core Registers (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:00.1 Host bridge: Intel Corporation Core Processor QuickPath Architecture System Address Decoder (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:02.0 Host bridge: Intel Corporation Core Processor QPI Link 0 (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:02.1 Host bridge: Intel Corporation Core Processor QPI Physical 0 (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:02.2 Host bridge: Intel Corporation Core Processor Reserved (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:02.3 Host bridge: Intel Corporation Core Processor Reserved (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0


--------------070108030009070806070409--
