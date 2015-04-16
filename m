From: George Dunlap <george.dunlap@eu.citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance regression
 on Xen
Date: Thu, 16 Apr 2015 09:56:22 +0100
Message-ID: <552F7936.9070205@eu.citrix.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"Stefano Stabellini" <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Paul Durrant" <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	<linux-arm-kernel@lists.infradead.org>,
	David Vrabel <david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:7550 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444AbbDPI4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 04:56:52 -0400
In-Reply-To: <1429121979.7346.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2015 07:19 PM, Eric Dumazet wrote:
> On Wed, 2015-04-15 at 19:04 +0100, George Dunlap wrote:
> 
>> Maybe you should stop wasting all of our time and just tell us what
>> you're thinking.
> 
> I think you make me wasting my time.
> 
> I already gave all the hints in prior discussions.

Right, and I suggested these two options:

"Obviously one solution would be to allow the drivers themselves to set
the tcp_limit_output_bytes, but that seems like a maintenance
nightmare.

"Another simple solution would be to allow drivers to indicate whether
they have a high transmit latency, and have the kernel use a higher
value by default when that's the case." [1]

Neither of which you commented on.  Instead you pointed me to a comment
that only partially described what the limitations were. (I.e., it
described the "two packets or 1ms", but not how they related, nor how
they related to the "max of 2 64k packets outstanding" of the default
tcp_limit_output_bytes setting.)

 -George


[1]
http://marc.info/?i=<CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
