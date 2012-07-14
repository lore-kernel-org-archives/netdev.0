From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 16:19:00 +0200
Message-ID: <1342275540.3265.9760.camel@edumazet-glaptop>
References: <20120713171835.GA26052@vault.local>
	 <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com>
	 <1342254042.3265.9017.camel@edumazet-glaptop>
	 <CAJd=RBAJOqJDSBpaaB+2-WU_pa5vChXSf6TbLH8fi3HNt6hZ9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Truschnigg <johannes@truschnigg.info>,
	linux-kernel@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Linux-Netdev <netdev@vger.kernel.org>
To: Hillf Danton <dhillf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63750 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab2GNOTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 10:19:06 -0400
In-Reply-To: <CAJd=RBAJOqJDSBpaaB+2-WU_pa5vChXSf6TbLH8fi3HNt6hZ9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-14 at 22:08 +0800, Hillf Danton wrote:
> On Sat, Jul 14, 2012 at 4:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Might be, or not (could be a NIC bug)
> >
> Dunno why sendfile sits in the layer of NIC and
> how they interact.

sendfile() relies heavily on TSO capabilities, a buggy NIC could
corrupt frame content on some obscure occasions.

We had some known cases on IPv6 for example.
