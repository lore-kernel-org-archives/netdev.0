From: Roland Dreier <roland@digitalvampire.org>
Subject: Re: IPv6 default routes timing out?
Date: Thu, 30 Jul 2009 09:58:53 -0700
Message-ID: <87k51q6raq.fsf@shaolin.home.digitalvampire.org>
References: <874osv8jyo.fsf@shaolin.home.digitalvampire.org>
	<1248914038.13447.17.camel@merlyn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:58147
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751469AbZG3Q7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 12:59:06 -0400
In-Reply-To: <1248914038.13447.17.camel@merlyn> (John Dykstra's message of "Wed, 29 Jul 2009 19:33:58 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > First thing I'd do is leave wireshark running overnight on the laptop
 > and see if the multicast router ads are making it to there.

Thanks, I did some more debugging it seems the issue is in the
router's (openbsd) wireless driver -- it thinks it is broadcasting
router advertisements but they aren't making it to the laptop.

So everything seems OK on the Linux side.

 - R.
