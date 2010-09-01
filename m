From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Wed, 1 Sep 2010 06:36:03 +0000
Message-ID: <20100901063602.GA6285@ff.dom.local>
References: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com> <20100831210101.3c059a91@leibniz> <4C7D5EBD.103@gmail.com> <AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com> <20100831214808.GA32141@ms2.inr.ac.ru> <20100831223402.GA7101@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Kruchinin <dkruchinin@acm.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55949 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab0IAGgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 02:36:09 -0400
Received: by bwz11 with SMTP id 11so5061345bwz.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 23:36:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100831223402.GA7101@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 02:34:02AM +0400, Alexey Kuznetsov wrote:
> Hello!
Hi!

> To Jarek: about the scripts. I do not think something will be broken
> by fixing this error. Eventually, if someone used "latency", he meant
> something about real latency. And even if the value was generated
> using the same wrong logic as tc did, using correct formula would just
> increase limit setting.

As I wrote earlier, I'm more worried about configs based on experience,
not logic. Dan's tests show there could be a difference, and I'm not
sure users cared about the logic, since it wasn't questioned until now.
Btw, there could be considered adding a new, alternative parameter, for
this, like rlatency etc. if it's so crucial. And, of course, it's only
my little "IMHO", I don't insist on anything.

Thanks,
Jarek P.
