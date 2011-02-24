From: Benjamin LaHaise <bcrl@kvack.org>
Subject: via-rhine -- VT6105M and checksum offloading
Date: Thu, 24 Feb 2011 13:58:05 -0500
Message-ID: <20110224185805.GI30393@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:33897 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752125Ab1BXTPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 14:15:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

I've recently noticed that one of the embedded systems I'm using (the 
PCEngines ALIXes) is becoming CPU bound under heavy network traffic.  
Upon investigation, it looks like the VT6105M isn't actually using the 
hardware checksum offloading support of the hardware.  Are there any 
known reasons why this isn't enabled (hardware bugs?)?  I'll test enabling 
it in the driver, but I figured it would be worth asking if this path 
has been explored already.  Cheers,

		-ben
