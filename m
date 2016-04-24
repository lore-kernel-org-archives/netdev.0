From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 1/3] gre: do not assign header_ops in collect
 metadata mode
Date: Sun, 24 Apr 2016 11:31:11 +0200
Message-ID: <20160424113111.76ff071a@griffin>
References: <cover.1461346798.git.jbenc@redhat.com>
	<7c34e7243a146fc5ccdf6349892355746741ff26.1461346798.git.jbenc@redhat.com>
	<CAOrHB_Dffj93ED0u+RQ89SneRn5YRGFB9piYYiTDFJ43ZGDpNQ@mail.gmail.com>
	<20160422232054.3f6b47da@griffin>
	<20160423014143.GC32327@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Simon Horman <simon.horman@netronome.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462AbcDXJbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 05:31:16 -0400
In-Reply-To: <20160423014143.GC32327@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Apr 2016 03:41:43 +0200, Thomas Graf wrote:
> On 04/22/16 at 11:20pm, Jiri Benc wrote:
> > On Fri, 22 Apr 2016 14:04:48 -0700, pravin shelar wrote:
> > > I think we should we return error in case of such configuration rather
> > > than silently ignoring it.
> > 
> > I thought about it and I'm not sure. We're not returning an error
> > currently, starting returning it now might be perceived as uAPI
> > breakage.
> > 
> > But given it doesn't work at all currently, there are apparently no
> > users yet. I'll wait for more feedback.
> 
> As a user, I would probably favour receiving an error for a configuration
> that can't possibly work and was not working before.

Okay, I'll change this in v2. Thanks, Pravin and Thomas.

 Jiri
