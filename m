From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2 3/3] gre: allow creation of gretap interfaces in
 metadata mode
Date: Tue, 26 Apr 2016 10:47:43 +0200
Message-ID: <20160426104743.36d19b5c@griffin>
References: <cover.1461495411.git.jbenc@redhat.com>
	<4917335385a75586c1f13b6a6d570d4cc5b0b132.1461495411.git.jbenc@redhat.com>
	<CAOrHB_BZkZhSOWqgsHXDM_3o+zkgCwRYwOL2hr33_p02if9Fxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377AbcDZIrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 04:47:48 -0400
In-Reply-To: <CAOrHB_BZkZhSOWqgsHXDM_3o+zkgCwRYwOL2hr33_p02if9Fxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Apr 2016 11:00:35 -0700, pravin shelar wrote:
> On Sun, Apr 24, 2016 at 4:00 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > The IFLA_GRE_REMOTE attribute does not make sense together with collect
> > metadata and is ignored in such case. However, iproute2 always sets it; it
> > will be zero if there's no remote address specified on the command line.
> >
> > Remove the check for non-zero IFLA_GRE_REMOTE when collect medata flag is
> > set.
> >
> Rather than cover up in ip_gre kernel module, why not just fix
> iproute2 to set the attribute correctly?

Well, who defines "correctly"? :-)

I can do that, it really doesn't matter. One way or the other, the
result will be the same. I'll move this to iproute2 in v3.

 Jiri
