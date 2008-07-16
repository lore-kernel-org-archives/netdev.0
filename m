From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Wed, 16 Jul 2008 09:36:24 -0700
Message-ID: <adafxq9bxbr.fsf@cisco.com>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE60E9F58@SHEXMB-01.global.atheros.com>
	<20080715211514.25848d8a@extreme>
	<72981EBCFD196144B7C6999B9FC34A9A3EE60EA59C@SHEXMB-01.global.atheros.com>
	<20080716085329.03e97b2a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jie Yang <Jie.Yang@Atheros.com>,
	"jeff\@garzik.org" <jeff@garzik.org>,
	David Miller <davem@davemloft.net>,
	"jcliburn\@gmail.com" <jcliburn@gmail.com>,
	"parag.warudkar\@gmail.com" <parag.warudkar@gmail.com>,
	Willy Tarreau <w@1wt.eu>,
	"oliver.schuster\@schweigstill.de" <oliver.schuster@schweigstill.de>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:19805 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbYGPQg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 12:36:26 -0400
In-Reply-To: <20080716085329.03e97b2a@extreme> (Stephen Hemminger's message of
	"Wed, 16 Jul 2008 08:53:29 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Output of checkpatch (scripts/checkpatch.pl in kernel source).
 > Personally, I am not a whitespace bigot, and don't think
 > all the warnings in checkpatch have to be fixed.
 > 
 > ----------
 > ERROR: patch seems to be corrupt (line wrapped?)
 > #121: FILE: drivers/net/atl1e/atl1e.h:9:
 > ree
 > 
 > WARNING: space prohibited between function name and open parenthesis '('
 > #212: FILE: drivers/net/atl1e/atl1e.h:97:
 > +       _tpd =3D (((_vlan) << (4)) | (((_vlan) >> 13) & 7) |\

It's kind of pointless to run checkpatch on a corrupted patch (the email
was quoted-printable and you didn't decode it back to text).  Of course
it's also better to send non-mangled patches.

 - R.
