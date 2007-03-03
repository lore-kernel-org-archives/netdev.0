From: Guido Guenther <agx@sigxcpu.org>
Subject: Re: [patch] at76_usb wireless driver
Date: Sat, 3 Mar 2007 16:00:29 +0100
Message-ID: <20070303150029.GA19940@bogon.ms20.nix>
References: <20070110145724.GA4171@bogon.ms20.nix> <20070223221230.GA9965@bogon.ms20.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from honk1.physik.uni-konstanz.de ([134.34.140.224]:59065 "EHLO
	honk1.physik.uni-konstanz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030291AbXCCPBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 10:01:00 -0500
Received: from localhost (localhost.localnet [127.0.0.1])
	by honk1.physik.uni-konstanz.de (Postfix) with ESMTP id 5749B3A993
	for <netdev@vger.kernel.org>; Sat,  3 Mar 2007 16:00:59 +0100 (CET)
Received: from honk1.physik.uni-konstanz.de ([127.0.0.1])
	by localhost (honk [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 23476-32 for <netdev@vger.kernel.org>;
	Sat, 3 Mar 2007 16:00:58 +0100 (CET)
Received: from bogon.sigxcpu.org (xdsl-84-44-179-203.netcologne.de [84.44.179.203])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by honk1.physik.uni-konstanz.de (Postfix) with ESMTP id 7A8283A992
	for <netdev@vger.kernel.org>; Sat,  3 Mar 2007 16:00:58 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20070223221230.GA9965@bogon.ms20.nix>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I'd be glad if someone could review the at76_usb wireless driver, it
adds support for the at76c503, at76c505 and at76c505a wireless USB
adapters. Since it exceeds the lists size limit, please
    git-clone http://honk.sigxcpu.org/git/at76c503a.git/

The projects homepage is:
    http://at76c503a.berlios.de/
The above git tree is functionally equivalent to the CVS version at
berlios but removes support for older kernels, older wireless
extensions, C99 style comments, commented out code and shifts things
around a little for better readability. This is only done to ease
reviewing - there are no functional changes over the CVS archive.

The driver was tested (and is in pracitical use) on at least i386, amd64
and powerpc.

Please note that I'm not the author of the driver, the driver itself
lists these copyright holders (but none of them showed up on the
mailing list during the last couple of months):

Copyright (c) 2002 - 2003 Oliver Kurth
Copyright (c) 2004 Joerg Albert <joerg.albert@gmx.de>
Copyright (c) 2004 Nick Jones
Copyright (c) 2004 Balint Seeber <n0_5p4m_p13453@hotmail.com>

Pavel Roskin, Maxim Grechkin and me were committing to CVS recently.
Cheers,
 -- Guido

