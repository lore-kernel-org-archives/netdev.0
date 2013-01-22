From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Tue, 22 Jan 2013 10:17:50 -0800
Message-ID: <50FED7CE.1030008@hp.com>
References: <20130122161038.GG4608@sociomantic.com> <1358873142.3464.3964.camel@edumazet-glaptop> <20130122165929.GH4608@sociomantic.com> <1358874800.3464.4002.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358874800.3464.4002.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> What is important is the backlog, and I guess you didn't increase it
> properly. The somaxconn default is quite low (128)

Leandro -

If that is being overflowed, I believe you should be seeing something like:

     14 SYNs to LISTEN sockets dropped

in the output of netstat -s on the system on which the server 
application is running.

rick
