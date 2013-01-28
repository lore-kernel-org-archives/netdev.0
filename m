From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Sun, 27 Jan 2013 21:21:32 -0800
Message-ID: <CAGK4HS_2=b3gJmDeBTbSmFYk4PB2epMUQE6nkr1XMGfFgmfHvw@mail.gmail.com>
References: <1358874800.3464.4002.camel@edumazet-glaptop>
	<50FED7CE.1030008@hp.com>
	<20130122184245.GJ4608@sociomantic.com>
	<50FF0C25.9000300@hp.com>
	<20130123104736.GK4608@sociomantic.com>
	<510039C8.7040401@hp.com>
	<20130124122223.GQ4608@sociomantic.com>
	<51018110.1070403@hp.com>
	<20130124192125.GD4608@sociomantic.com>
	<5102225E.2040506@gmail.com>
	<20130125100525.GE4608@sociomantic.com>
	<5105E6F2.2010805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Leandro Lucarella <leandro.lucarella@sociomantic.com>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nivedita Singhvi <niveditasinghvi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5105E6F2.2010805@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +    { "ListenDrops", N_("%u SYNs to LISTEN sockets dropped"), opt_number },
>
> (see the file debian/patches/CVS-20081003-statistics.c_sync.patch
>  in the net-tools src)
>
> i.e., the netstat pkg is printing the value of the TCPEXT MIB counter
> that's counting TCPExtListenDrops.
>
> Theoretically, that number should be the same as that printed by nstat,
> as they are getting it from the same kernel stats counter. I have not
> looked at nstat code (I actually almost always dump the counters from
> /proc/net/{netstat + snmp} via a simple prettyprint script (will send
> you that offline).
>

nstat pretty much does what you describe which is to parse the
/proc/net files(s) and
print the contents. This is one advantage of nstat over netstat. When
you add a new MIB, you
do not need to update nstat.

> If the nstat and netstat counters don't match, something is fishy.
> That nstat output is broken.
>
