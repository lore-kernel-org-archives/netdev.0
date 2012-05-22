From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: tcp timestamp issues with google servers
Date: Tue, 22 May 2012 10:38:57 -0700
Message-ID: <CAGK4HS8b2GSub02ShhofCrYQ1XnOT7Rrjm3KcOhCFFkUF1QqBA@mail.gmail.com>
References: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu>
	<1337278363.3403.39.camel@edumazet-glaptop>
	<87zk90s0em.fsf@tucsk.pomaz.szeredi.hu>
	<1337701259.3361.208.camel@edumazet-glaptop>
	<87mx50rz34.fsf@tucsk.pomaz.szeredi.hu>
	<CAGK4HS9cGnOcoLAL1pggWvMG1B40rWyqc3BHsddUvnii4EvTcQ@mail.gmail.com>
	<1337705285.3361.229.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Miklos Szeredi <miklos@szeredi.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337705285.3361.229.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Maybe tcptraceroute[1] can help you figure this out.
>>
>> [1] http://michael.toren.net/code/tcptraceroute/
>
>
> The transparent proxy can intercept TCP connections to port 80/443, and
> let ICMP being NATed by the box.

Just to be clear..tcptraceroute uses TCP SYN packets to trace the
route instead of using ICMP packets used by vanilla traceroute
precisely because
of the issue you raised.
The idea is that if the connection is getting terminated at a
middlebox, the trace will end there. Otherwise, the trace route will
end
at destination (google in this case). This avoids the problems of ICMP
and TCP flows being treated differently by the middlebox.
Is this approach workable?

Thanks,
Vijay
