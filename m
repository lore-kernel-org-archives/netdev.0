From: "Holger Hoffstaette" <holger@wizards.de>
Subject: Re: Reproducible data corruption with sendfile+vsftp - splice regression?
Date: Sat, 15 Dec 2007 11:24:20 +0100
Message-ID: <pan.2007.12.15.10.24.20.327500@wizards.de>
References: <pan.2007.11.29.23.42.52.661624@wizards.de> <474FC4D9.3020506@cosmosbay.com> <pan.2007.11.30.09.20.24.737500@wizards.de> <475055EE.9060105@hp.com> <pan.2007.12.02.16.00.03.568000@wizards.de> <pan.2007.12.02.20.49.42.675000@wizards.de> <20071205225429.GA10186@electric-eye.fr.zoreil.com> <pan.2007.12.06.09.28.08.913625@wizards.de> <20071206184426.GA32599@electric-eye.fr.zoreil.com> <pan.2007.12.13.02.19.40.200510@wizards.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:52514 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbXLOKYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2007 05:24:32 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1J3UC6-0004Yf-7l
	for netdev@vger.kernel.org; Sat, 15 Dec 2007 10:24:30 +0000
Received: from port-87-234-135-174.dynamic.qsc.de ([87.234.135.174])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2007 10:24:30 +0000
Received: from holger by port-87-234-135-174.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2007 10:24:30 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2007 03:19:43 +0100, Holger Hoffstaette wrote:

> I have now gone back to enable TSO since vsftp with sendfile really seems
> to be the only app that causes this. I have simply set it to
> use_sendfile=NO and no corruption occurs at all; the machine is stable and
> fast.

In the good tradition of proving myself wrong I can reliably create
corrupted files by wget-ting from apache (with sendfile enabled) as
well, so no more TSO after all. No TSO, no corruption.
The same also happens on a different machine with a r8169 (same model).
Tickless kernel makes no difference either. Shot in the dark, but hey..

Holger


