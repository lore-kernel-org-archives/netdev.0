From: Chris Verges <cverges@sentient-energy.com>
Subject: Re: Established sockets remain open after iface down or address lost
Date: Tue, 1 Oct 2013 10:07:40 -0700
Message-ID: <20131001170740.GA9331@cverges-dev-lnx.sentient-energy.com>
References: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
 <CAMrnHh6Lr9q27yiSmJ-EbJMTeUVyf9650vK+6QmbfTVfz_omxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:54078 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab3JARHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 13:07:44 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so7771344pad.14
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 10:07:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMrnHh6Lr9q27yiSmJ-EbJMTeUVyf9650vK+6QmbfTVfz_omxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 01, 2013 at 08:33:04PM +0400, Alexey Kuznetsov wrote:
> > P.S.  I apologize in advance if I missed this answer in the netdev
> > archives.
> 
> FYI googling f.e. "netdev tcp remove local address" instantly  finds
> all that you want to know. Namrly, subj: Re: "TCP shutdown behaviour
> when deleting local IP addresses"

Oustanding.  Thank you!  I really appreciate the pointer to bring me up
to speed on the history.  It sounds like Mikael and I share a similar
desire and rationale for why such a thing would be useful.

Your comment regarding the tcp hash table scanning is what I was
planning to code up, though it sounds like some amount of effort was
made in this attempt and abandoned.  Would you happen to know where any
out-of-kernel code related to this might be parked if one wanted to
continue this effort?

I do agree with Mikael that offloading this from the kernel to some kind
of connection manager would be ideal.  I'll ponder this some more....

Again, many thanks for the help.

Chris
