From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp timestamp issues with google servers
Date: Tue, 22 May 2012 18:48:05 +0200
Message-ID: <1337705285.3361.229.camel@edumazet-glaptop>
References: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu>
	 <1337278363.3403.39.camel@edumazet-glaptop>
	 <87zk90s0em.fsf@tucsk.pomaz.szeredi.hu>
	 <1337701259.3361.208.camel@edumazet-glaptop>
	 <87mx50rz34.fsf@tucsk.pomaz.szeredi.hu>
	 <CAGK4HS9cGnOcoLAL1pggWvMG1B40rWyqc3BHsddUvnii4EvTcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Miklos Szeredi <miklos@szeredi.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGK4HS9cGnOcoLAL1pggWvMG1B40rWyqc3BHsddUvnii4EvTcQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-22 at 09:38 -0700, Vijay Subramanian wrote:
> > Okay.  Is there a way to find out whether there is a middlebox or not?
> >
> 
> Miklos,
> Maybe tcptraceroute[1] can help you figure this out.
> 
> Hope this helps.
> Vijay
> 
> [1] http://michael.toren.net/code/tcptraceroute/


The transparent proxy can intercept TCP connections to port 80/443, and
let ICMP being NATed by the box.

So its better to check of the delay between SYN and SYNACK is roughly
independent of the HTTP server.

If you have very large range of delays, you can conclude its not a
transparent proxy.
