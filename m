From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Thu, 02 May 2013 15:55:37 +0800
Message-ID: <1367481337.2415.21.camel@cr0>
References: <1367311395-15891-5-git-send-email-amwang@redhat.com>
	 <87r4hscr7s.fsf@nemi.mork.no> <1367313956.3216.18.camel@cr0>
	 <20130430.150547.2297961494334074636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org, dlstevens@us.ibm.com,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755842Ab3EBHz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 03:55:57 -0400
In-Reply-To: <20130430.150547.2297961494334074636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 15:05 -0400, David Miller wrote:
> Your patch has had large, major, shortcomings every single iteration.

This is due to people including you only point out one problem per
iteration, for some reason I don't understand...

For example, you pointed out IPv6=M issue in v5, and then pointed out
disable_ipv6 issue in v6. Until you pointed them out, I even wasn't
aware of them. All the problems I have fixed, except the naming of
struct fields which I still don't agree, exist in v1, there is no
regression since v1.

As always, it is _highly_ appreciated if all of you can point as many
issues as you can in a single iteration, so that I can fix them all in
one update (if I can fix), this also saves me _a lot_ of time,
obviously.

So, I even don't understand what you are complaining about. :) I am
trying my best to address all the issues you pointed out including the
one that I don't agree at all, except the one I can't fix right now
(scope id). If anything I can improve on my side, please explicitly let
me know.

Again, I am _not_ an IPv6 expert, I am sure there are still some other
issues like disable_ipv6 that I am still not aware of, so please don't
expect me to be able to fix all bugs alone at one time, I am trying to
fix them one by one, and this is the best that I can do.

Thanks.
