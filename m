From: Guenther Thomsen <gthomsen@bluearc.com>
Subject: Re: sky2 driver problems in 2.6.17-rc2-git6 (was: Re: kernel panic (on DHCP discover?) in sky2 driver of 2.6.17-rc1)
Date: Wed, 26 Apr 2006 10:41:07 -0700
Message-ID: <200604261041.08731.gthomsen@bluearc.com>
References: <200604121442.56750.gthomsen@bluearc.com> <200604251706.25617.gthomsen@bluearc.com> <20060426094445.6b892761@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmimesweeper.bluearc.com ([63.203.197.133]:47119 "EHLO
	us-mimesweeper.terastack.bluearc.com") by vger.kernel.org with ESMTP
	id S932312AbWDZRlO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 13:41:14 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060426094445.6b892761@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 26 April 2006 09:44, Stephen Hemminger wrote:
> On Tue, 25 Apr 2006 17:06:25 -0700
>
> Guenther Thomsen <gthomsen@bluearc.com> wrote:
[..]
> > Considering the recent NFS changes, I tried to get the system into
> > this state using just ttcp. With some determination, three more
> > hosts and a few million packets, I succeeded. This time eth0
> > truncated packets and traffic slowed to a crawl (~1 good packet
> > every 2s).
> >
> > Some progress has been made, but it's not quite solid yet.
>
> Are you saturating both ports on the card or only one?

On the system under test I started four ttcp sessions: two senders and 
two receivers (the second one on a non-standard port). One pair for 
each port (device). I'm not sure, to which degree the device was 
saturated. It certainly should have been, since the remote hosts are 
capable of line rate, but I found the sending ttcp sessions on the 
system under test to be slow, as long as traffic was incoming.

best regards
	Guenther
