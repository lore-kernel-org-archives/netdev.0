From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [BUG] tg3 cannot do PXE (loses MAC address) after soft reboot
Date: Mon, 17 Sep 2007 13:29:35 +0200
Message-ID: <200709171329.35656.netdev@axxeo.de>
References: <20070913083918.GA5386@xanadu.blop.info> <200709141014.20635.netdev@axxeo.de> <1189795942.9540.155.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Lucas Nussbaum" <lucas.nussbaum@imag.fr>,
	"netdev" <netdev@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:3203 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755297AbXIQL3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 07:29:49 -0400
In-Reply-To: <1189795942.9540.155.camel@dell>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan schrieb:
> On Fri, 2007-09-14 at 10:14 +0200, Ingo Oeser wrote:
> > Is it enough to parse the first number in the firmware via simple_strtoul()?
> 
> No, it's not.  We need to check the number after the '.' and possibly an
> alphabet at the end as well.  Worse yet, the version may be different
> for different chips.

Ah, I see. I thought the first number is some constantly increasing
internal version number from your SCM[1] and the other is the 
"marketing release number".

Thank you for explaining this. And that different version for different
chips issue make it really hard. I can see that now.
 
> We'll see if we can come up with a simple way to detect the problem.

That would help your users (like the customers of my employer).
Admins and system vendors will love you for that :-)


Best Regards

Ingo Oeser

[1] Source Control Management e.g. cvs, subversion, git
