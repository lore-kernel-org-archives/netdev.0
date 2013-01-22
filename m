From: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Tue, 22 Jan 2013 19:42:45 +0100
Message-ID: <20130122184245.GJ4608@sociomantic.com>
References: <20130122161038.GG4608@sociomantic.com>
 <1358873142.3464.3964.camel@edumazet-glaptop>
 <20130122165929.GH4608@sociomantic.com>
 <1358874800.3464.4002.camel@edumazet-glaptop>
 <50FED7CE.1030008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50FED7CE.1030008@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 22, 2013 at 10:17:50AM -0800, Rick Jones wrote:
> >What is important is the backlog, and I guess you didn't increase it
> >properly. The somaxconn default is quite low (128)
> 
> Leandro -
> 
> If that is being overflowed, I believe you should be seeing something like:
> 
>     14 SYNs to LISTEN sockets dropped
> 
> in the output of netstat -s on the system on which the server
> application is running.

What is that value reporting exactly? Because we are using syncookies,
and AFAIK with that enabled, all SYNs are being replied, and what the
listen backlog is really limitting is the "completely  established
sockets waiting to be accepted", according to listen(2). What I don't
really know to be honest, is what a "completely established socket" is,
does it mean that the SYN,ACK was sent, or the ACK was received back?

Also, from the client side, when is the connect(2) call done? When the
SYN,ACK is received?

Thanks!

-- 
Leandro Lucarella
sociomantic labs GmbH
http://www.sociomantic.com
