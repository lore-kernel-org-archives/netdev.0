From: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
Subject: Re: PATCH Re: udp weirdness
Date: Wed, 2 Oct 2002 13:13:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021002111326.GG357@hookipa>
References: <3D99B6C7.3010302@nortelnetworks.com> <200210011531.TAA19943@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Friesen <cfriesen@nortelnetworks.com>, hadi@cyberus.CA,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200210011531.TAA19943@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > I may have to poke around...if nothing else I'll learn more about the 
> > networking code...
> 
> It is difficult task, if possible at all.
> 
> The main obstacle is that we must not block after select() succeeded,
> otherwise applications will lockup. Taking into account nature of datagram
> services (and generally of networking services, where routes change et al.)
> you do not know at time of select(), where the datagram will go.
> So, blocking can be made only based on a criterium not depending on this.
> problems with silent losses. People just do not care about this, so
> they get the thing which they deserve.

Alexey,

Would you mind explaining a bit more why apps will lockup if we block
after select() succeeded. Or anyone?

Thx.

	Eric.
