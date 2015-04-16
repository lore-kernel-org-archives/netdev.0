From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Thu, 16 Apr 2015 05:42:16 -0700
Message-ID: <1429188136.7346.198.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
	 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552E9E8D.1080000@eu.citrix.com>
	 <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA2BC.5000707@eu.citrix.com>
	 <1429120373.7346.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA844.5010308@eu.citrix.com>
	 <1429121979.7346.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552F7936.9070205@eu.citrix.com> <552F7EF4.9030107@iogearbox.net>
	 <552F887A.4060708@eu.citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	linux-arm-kernel@lists.infradead.org,
	David Vrabel <david.vrabel@citrix.com>
To: George Dunlap <george.dunlap@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38491 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753592AbbDPMmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 08:42:19 -0400
In-Reply-To: <552F887A.4060708@eu.citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-16 at 11:01 +0100, George Dunlap wrote:

> He suggested that after he'd been prodded by 4 more e-mails in which two
> of us guessed what he was trying to get at.  That's what I was
> complaining about.

My big complain is that I suggested to test to double the sysctl, which
gave good results.

Then you provided a patch using a 8x factor. How does that sound ?

Next time I ask a raise, I should try a 8x factor as well, who knows,
it might be accepted.
