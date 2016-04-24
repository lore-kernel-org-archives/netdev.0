From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2 1/3] gre: do not assign header_ops in collect
 metadata mode
Date: Sun, 24 Apr 2016 16:45:04 +0300
Message-ID: <571CCDE0.9060902@cogentembedded.com>
References: <cover.1461495411.git.jbenc@redhat.com>
 <bd50f4691e9edc28c5a9ec861863f7f6cf316077.1461495411.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36472 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637AbcDXNpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 09:45:06 -0400
Received: by mail-lb0-f174.google.com with SMTP id ys16so65650328lbb.3
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 06:45:05 -0700 (PDT)
In-Reply-To: <bd50f4691e9edc28c5a9ec861863f7f6cf316077.1461495411.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/24/2016 2:00 PM, Jiri Benc wrote:

> In ipgre mode (i.e. not gretap) with collect metadata flag set, the tunnel
> is incorrectly assumed to be mGRE in NBMA mode (see commit 6a5f44d7a048c).

    Didn't checkpatch.pl complain about the commit citing style?

> This is not the case, we're controlling the encapsulation addresses by
> lwtunnel metadata. And anyway, assigning dev->header_ops in collect metadata
> mode does not make sense.
>
> Similarly, when a multicast remote IP address is set together with the
> collect metadata flag, the processing described above would happen, too. As
> there's not much sense in specifying remote/local IP address for lwtunnels,
> reject such configuration.
>
> v2: Reject configuration specifying both remote/local address and collect
>      metadata flag.
>
> Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
[...]

MBR, Sergei
