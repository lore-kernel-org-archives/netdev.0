From: Fathi Boudra <fabo@debian.org>
Subject: Re: [Bugme-new] [Bug 13803] New: hso: Tx timed out.
Date: Tue, 1 Sep 2009 15:44:42 +0200
Message-ID: <6a2e33620909010644k38808d7mda7323f17252f3f2@mail.gmail.com>
References: <bug-13803-10286@http.bugzilla.kernel.org/>
	 <20090723154337.709ca0cd.akpm@linux-foundation.org>
	 <6a2e33620907250356o7a50108jfe59ae5e17aec03c@mail.gmail.com>
	 <4A71991E.90308@option.com>
Reply-To: fabo@debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jan Dumon <j.dumon@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f188.google.com ([209.85.211.188]:39932 "EHLO
	mail-yw0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805AbZIANok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 09:44:40 -0400
In-Reply-To: <4A71991E.90308@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2009 at 2:59 PM, Jan Dumon<j.dumon@option.com> wrote:
> Is still possible to send AT commands and get any network traffic through
> once this problem occurred, or is there no communication at all possible
> with the module ?

no it's not possible to send other AT command.
Minicom fails to connect on any ttyHSx port.

> Can you try again with debug enabled (module parameter debug=0x1F) ?

find attached the log file.

> Since it works on USB 1.1 but not on USB 2.0, my first guess would be that
> there's something wrong with the host controller or the host controller
> driver.

I should also mention I'm using a Transmeta Crusoe CPU board.
