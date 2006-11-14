From: "Michal Pokrywka" <mpokrywka@hoga.pl>
Subject: Re: [Bugme-new] [Bug 7502] New: sunhme not working with 2.6.18 on x86
Date: Tue, 14 Nov 2006 02:50:22 +0100
Message-ID: <1170.20061114025022.mpokrywka@hoga.pl>
References: <200611130048.kAD0mduX009385@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, <netdev@vger.kernel.org>,
	"Michal Pokrywka" <mpokrywka@hoga.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from output.infocity.pl ([212.244.112.51]:23157 "HELO pop3.hoga.pl")
	by vger.kernel.org with SMTP id S1755375AbWKNBwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 20:52:06 -0500
To: "David S. Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20061112213648.e4b91939.akpm@osdl.org>
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'd have expected that this would have been caused by i386 platform
> borkage.  But in the debian bug report, Michal has fingered davem's
> http://www.kernel.org/git/?p=linux/kernel/git/stable/linux-2.6.18.y.
> git;a=commit;h=050bbb196392b9c178f82b1205a23dd2f915ee93
> as the cause.
> 
> Michal, what makes you believe that this particualr patch is to
> blame?

Sorry, I'm not git expert, I only browsed sunhme.c changes through
http interface and I downloaded a11 driver revisions between what
I considered 2.6.17 driver (by date) and latest revision.
I compiled all revisions by hand and insmoded all these modules
until driver worked. Probably I didn't mentioned it in bug report,
but after loading working driver and kernel assigning correct
interrupts as seen in dmesg, all driver revisions loaded afterwards
worked, even those bad.
>From my pov driver is broken, because older version works with
2.6.18.

Regards
Michal Pokrywka
