From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/3] gre: do not assign header_ops in collect
 metadata mode
Date: Sat, 23 Apr 2016 03:41:43 +0200
Message-ID: <20160423014143.GC32327@pox.localdomain>
References: <cover.1461346798.git.jbenc@redhat.com>
 <7c34e7243a146fc5ccdf6349892355746741ff26.1461346798.git.jbenc@redhat.com>
 <CAOrHB_Dffj93ED0u+RQ89SneRn5YRGFB9piYYiTDFJ43ZGDpNQ@mail.gmail.com>
 <20160422232054.3f6b47da@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33494 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbcDWBlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 21:41:47 -0400
Received: by mail-wm0-f48.google.com with SMTP id 127so12748723wmz.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 18:41:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160422232054.3f6b47da@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/16 at 11:20pm, Jiri Benc wrote:
> On Fri, 22 Apr 2016 14:04:48 -0700, pravin shelar wrote:
> > I think we should we return error in case of such configuration rather
> > than silently ignoring it.
> 
> I thought about it and I'm not sure. We're not returning an error
> currently, starting returning it now might be perceived as uAPI
> breakage.
> 
> But given it doesn't work at all currently, there are apparently no
> users yet. I'll wait for more feedback.

As a user, I would probably favour receiving an error for a configuration
that can't possibly work and was not working before.
