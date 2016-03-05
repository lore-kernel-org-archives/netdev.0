From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [iproute PATCH 12/12] doc: Add my article about tc, filters and
 actions
Date: Fri, 4 Mar 2016 17:40:13 -0800
Message-ID: <20160305014011.GA63767@ast-mbp.thefacebook.com>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
 <1457093507-25601-13-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36734 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989AbcCEBkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 20:40:19 -0500
Received: by mail-pa0-f49.google.com with SMTP id fi3so41858651pac.3
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 17:40:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457093507-25601-13-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 01:11:47PM +0100, Phil Sutter wrote:
> Signed-off-by: Phil Sutter <phil@nwl.cc>

great to see TC doc!
Few comments:

> +TC, the Traffic Control utility, has been there for a very long time - forever
> +in my humble perception. It is still (and has ever been if I'm not mistaken) the
> +only tool to configure QoS in Linux.

please make the doc less subjective. The above paragraph can be removed.

> +\section*{Conclusion}
> +
> +My personal impression is that although the \cmd{tc} utility is an absolute
> +necessity for anyone aiming at doing QoS in Linux professionally, there are way
> +too many loose ends and trip wires present in it's environment. Contributing to
> +this is the fact, that much of the non-essential functionality is redundantly
> +available in netfilter. Another problem which adds weight to the first one is a
> +general lack of documentation. Of course, there are many HOWTOs and guides in
> +the internet, but since it's often not clear how up to date these are, I prefer
> +the usual resources such as man or info pages. Surely nothing one couldn't fix
> +in hindsight, but quality certainly suffers if the original author of the code
> +does not or can not contribute to that.

This one is also very subjective and not suitable for the iproute2 doc.
Please remove it.

> +All that being said, once the steep learning curve has been mastered, the
> +conglomerate of (classful) qdiscs, filters and actions provides a highly
> +sophisticated and flexible infrastructure to perform QoS, which plays nicely
> +along with routing and firewalling setups.

The rest of the doc is great. Thank you.
