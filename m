From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: iproute2: bash completion function for tc
Date: Wed, 27 Apr 2016 20:19:26 -0700
Message-ID: <20160428031923.GA76700@ast-mbp.thefacebook.com>
References: <571F1891.1030004@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vincent Jardin <vincent.jardin@6wind.com>,
	netdev@vger.kernel.org
To: Quentin Monnet <quentin.monnet@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35024 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbcD1DT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 23:19:28 -0400
Received: by mail-pa0-f49.google.com with SMTP id iv1so26951470pac.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 20:19:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <571F1891.1030004@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 09:28:17AM +0200, Quentin Monnet wrote:
> Hi Jamal, Stephen,
> 
> I searched for a function providing auto-completion for `tc` utility in
> bash, but I found none. So I have created one, and I would like share it
> with the community. It is available here:
> https://github.com/6WIND/tc_bash-completion/blob/master/tc
> I would like to make it easily available to tc users, so here is a
> twofold request:
> 
> * I do not know where to submit the code. Should I submit here on netdev
> for inclusion in iproute2 package, or rather to the bash-completion
> repository on GitHub? I feel like it would receive better feedback and
> updates if pushed to iproute2. Could you please provide some advice here?
> * The completion for `tc` seems to work well; I have tested it with many
> commands, but I am no tc expert, and there are probably some cases where
> the completion fails to propose the correct choices. I would be really
> interested in any feedback/bug reports that you, or anyone on this list
> who uses tc, could provide.

that looks very interesting.
I think making it a part of iproute2 is a good thing.
How about installing it into /etc/iproute2/ ?
Stephen, any comments?
