From: Alex Dubov <oakad@yahoo.com>
Subject: Re: iproute2: make arpd daemon write pid file on fork
Date: Sun, 14 Aug 2011 22:42:08 -0700 (PDT)
Message-ID: <1313386928.11965.YahooMailNeo@web121001.mail.ne1.yahoo.com>
References: <1313080925.3635.YahooMailNeo@web121018.mail.ne1.yahoo.com> <20110811110029.023a5955@nehalam.ftrdhcpuser.net> <201108121623.24984.oakad@yahoo.com> <20110812091547.17c40798@nehalam.ftrdhcpuser.net>
Reply-To: Alex Dubov <oakad@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm28-vm1.bullet.mail.ne1.yahoo.com ([98.138.91.35]:35755 "HELO
	nm28-vm1.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751694Ab1HOFmK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 01:42:10 -0400
In-Reply-To: <20110812091547.17c40798@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----

> 
>>  The included patch makes arpd write it's own pid file after fork, in a 
> common 
>>  LSB fashion, so as to better inter-operate with start up scripts. Removal 
> of 
>>  stale pid files is handled elsewhere.
> 
> I already checked in a version which has the -p pidfile option.
>

Thanks for that.
It will be enough for arpd to fit with the rest of init scripts.

