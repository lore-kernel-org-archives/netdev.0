From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Tue, 02 Jun 2015 09:16:12 -0700
Message-ID: <1433261772.1895.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <552E9E8D.1080000@eu.citrix.com>
	 <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA2BC.5000707@eu.citrix.com>
	 <1429120373.7346.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA844.5010308@eu.citrix.com>
	 <1429121979.7346.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552F7936.9070205@eu.citrix.com> <552F7EF4.9030107@iogearbox.net>
	 <552F887A.4060708@eu.citrix.com>
	 <1429188136.7346.198.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150602095237.GL19403@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: George Dunlap <george.dunlap@eu.citrix.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
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
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:34984 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759042AbbFBQQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 12:16:16 -0400
In-Reply-To: <20150602095237.GL19403@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-02 at 10:52 +0100, Wei Liu wrote:
> Hi Eric
> 
> Sorry for coming late to the discussion.
> 
> On Thu, Apr 16, 2015 at 05:42:16AM -0700, Eric Dumazet wrote:
> > On Thu, 2015-04-16 at 11:01 +0100, George Dunlap wrote:
> > 
> > > He suggested that after he'd been prodded by 4 more e-mails in which two
> > > of us guessed what he was trying to get at.  That's what I was
> > > complaining about.
> > 
> > My big complain is that I suggested to test to double the sysctl, which
> > gave good results.
> > 
> 
> Do I understand correctly that it's acceptable to you to double the size
> of the buffer? If so I will send a patch to do that.

Absolutely.
