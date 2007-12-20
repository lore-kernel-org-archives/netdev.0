From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 0/3] XFRM audit fixes/additions for net-2.6.25
Date: Thu, 20 Dec 2007 16:42:14 -0500
Message-ID: <20071220214200.12122.89628.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com
To: netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:38882
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751181AbXLTVp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 16:45:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three patches backed against net-2.6.25 from today.  Some of the audit
messages are a little difficult to test by their nature but I've verified
that I'm still able to send/receive IPsec protected traffic with the patches
applied.

The first patch was posted before but David decided it best to split the
patch so some parts could be pulled into 2.6.24; the patch was split and
the 2.6.24 bits were accepted (the SPI byteorder fix) so patch #1 in the
series is what is left for 2.6.25.

The second patch was posted before as an RFC patch without anyone complaining
too loudly.  Eric Paris made some suggestions about better handling of the
"op=" audit field and I've tried to take that into account with this patch.

The final patch is the audit replay counter overflow issue fix that has been
talked about on netdev.  This sounded like the best course of action from the
discussion but if I'm wrong, just drop this patch and I'll cook up something
else to solve the problem.

Thanks.

--
paul moore
linux security @ hp

