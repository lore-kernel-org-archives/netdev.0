From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 1/3] gre: do not assign header_ops in collect
 metadata mode
Date: Fri, 22 Apr 2016 23:20:54 +0200
Message-ID: <20160422232054.3f6b47da@griffin>
References: <cover.1461346798.git.jbenc@redhat.com>
	<7c34e7243a146fc5ccdf6349892355746741ff26.1461346798.git.jbenc@redhat.com>
	<CAOrHB_Dffj93ED0u+RQ89SneRn5YRGFB9piYYiTDFJ43ZGDpNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbcDVVU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 17:20:59 -0400
In-Reply-To: <CAOrHB_Dffj93ED0u+RQ89SneRn5YRGFB9piYYiTDFJ43ZGDpNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Apr 2016 14:04:48 -0700, pravin shelar wrote:
> I think we should we return error in case of such configuration rather
> than silently ignoring it.

I thought about it and I'm not sure. We're not returning an error
currently, starting returning it now might be perceived as uAPI
breakage.

But given it doesn't work at all currently, there are apparently no
users yet. I'll wait for more feedback.

 Jiri
