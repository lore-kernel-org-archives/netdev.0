From: Jesper Krogh <jesper@krogh.cc>
Subject: Support for Intel 82598EB 10-Gigabit AT2 Server Adapter
Date: Fri, 04 Dec 2009 18:33:25 +0100
Message-ID: <4B1947E5.2020205@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:46951 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932249AbZLDRjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 12:39:08 -0500
Received: from localhost (localhost [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id 782B9153095
	for <netdev@vger.kernel.org>; Fri,  4 Dec 2009 18:33:30 +0100 (CET)
Received: from shrek.krogh.cc ([127.0.0.1])
	by localhost (shrek.krogh.cc [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OsPCRz4iHWSa for <netdev@vger.kernel.org>;
	Fri,  4 Dec 2009 18:33:26 +0100 (CET)
Received: from [90.184.13.137] (unknown [90.184.13.137])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: jesper@krogh.cc)
	by shrek.krogh.cc (Postfix) with ESMTPSA id 657E6152B3B
	for <netdev@vger.kernel.org>; Fri,  4 Dec 2009 18:33:26 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I just got two Intel 82598EB 10-Gigabit AT2 Server Adapter i sort of
assumed that they "just worked" since I have a AF-adapter (SR-fiber),
that works flawlessly and it it "just another media" in the other end.

But as of 2.6.31.6 the pci-ids is not registered in modules.pcimap

82:00.0 0200: 8086:150b (rev 01)
84:00.0 Ethernet controller: Intel Corporation 82598EB 10-Gigabit AT2
Server Adapter (rev 01)

And the adapter does not produce any ethX interfaces for usage when the
ixgbe drivers is loaded.

Is it as simple as just adding the identifiers to the module-map or is
there a patch flying around somewhere?

Thanks.

Jesper

