From: Florian Weimer <fweimer@bfk.de>
Subject: Re: e1000 driver and samba
Date: Tue, 18 Sep 2007 15:39:59 +0200
Message-ID: <82k5qoxfbk.fsf@mid.bfk.de>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	<36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	<20070918020358.d50653d5.billfink@mindspring.com>
	<ygfps0g8lj0.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bill Fink <billfink@mindspring.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"L F" <lfabio.linux@gmail.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, <netdev@vger.kernel.org>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.bfk.de ([193.227.124.2]:53731 "EHLO mx01.bfk.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754371AbXIRN5s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 09:57:48 -0400
In-Reply-To: <ygfps0g8lj0.fsf@janus.isnogud.escape.de> (Urs Thuermann's message of "18 Sep 2007 09:45:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Urs Thuermann:

> How can a corrupted frame pass the TCP checksum check?

The TCP/IP checksums are extremely weak.  If the corruption is due to
defective SRAM or something like that, it's likely that it causes an
error pattern which is 16-bit-aligned.  And an even number of
16-bit-aligned bit flips is not detected by the TCP checksum. 8-(

Actually, nobody should use TCP without application-level checksums
for that reason.  But of course, there is HTTP.

--=20
=46lorian Weimer                <fweimer@bfk.de>
BFK edv-consulting GmbH       http://www.bfk.de/
Kriegsstra=DFe 100              tel: +49-721-96201-1
D-76133 Karlsruhe             fax: +49-721-96201-99
