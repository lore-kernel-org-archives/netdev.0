From: Jan Dumon <j.dumon@option.com>
Subject: Re: [Bugme-new] [Bug 13803] New: hso: Tx timed out.
Date: Thu, 30 Jul 2009 14:59:10 +0200
Message-ID: <4A71991E.90308@option.com>
References: <bug-13803-10286@http.bugzilla.kernel.org/>	 <20090723154337.709ca0cd.akpm@linux-foundation.org> <6a2e33620907250356o7a50108jfe59ae5e17aec03c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: fabo@debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:38695 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbZG3NJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 09:09:33 -0400
In-Reply-To: <6a2e33620907250356o7a50108jfe59ae5e17aec03c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is still possible to send AT commands and get any network traffic through once this problem 
occurred, or is there no communication at all possible with the module ?

Can you try again with debug enabled (module parameter debug=0x1F) ?

Since it works on USB 1.1 but not on USB 2.0, my first guess would be that there's something wrong 
with the host controller or the host controller driver.
