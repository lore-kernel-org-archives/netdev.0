From: jaganav@us.ibm.com
Subject: RE: Linux support for RDMA
Date: Fri,  1 Apr 2005 20:59:46 -0500
Message-ID: <1112407186.424dfc92dc37a@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Asgeir Eiriksson <asgeir@chelsio.com>, "H. Peter Anvin" <hpa@zytor.com>,
        Roland Dreier <roland@topspin.com>, open-iscsi@googlegroups.com,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dima@neterion.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting Dmitry Yusupov <dima@neterion.com>:

> On Fri, 2005-04-01 at 15:50 -0800, Asgeir Eiriksson wrote:
> > Venkat
> > 
> > Your assessment of the IB vs. Ethernet latencies isn't necessarily
> > correct.
> > - you already have available low latency 10GE switches (< 1us
> > port-to-port)
> > - you already have available low latency (cut-through processing) 10GE
> > TOE engines
> > 
> > The Veritest verified 10GE TOE end-to-end latency is < 10us today
> > (end-to-end being from a Linux user-space-process to a Linux
> > user-space-process through a switch; full report with detail of the
> > setup is available at
> > http://www.chelsio.com/technology/Chelsio10GbE_Fujitsu.pdf)
> > 
> > For comparison: the published IB latency numbers are around 5us today
> > and those use a polling receiver, and those don't include a context
> > switch(es) as does the Ethernet number quoted above.
> 
> yep. I should agree in here. On 10Gbps network latencies numbers are
> around 5-15us. Even with non-TOE card, I managed to get 13us latency
> with regular TCP/IP stack.
> 
> [root@localhost root]# ./nptcp -a -t -l 256 -u 98304 -i 256 -p 5100 -P - h
> 17.1.1.227
> Latency: 0.000013
> Now starting main loop
>   0:       256 bytes    7 times -->  131.37 Mbps in 0.000015 sec
>   1:       512 bytes   65 times -->  239.75 Mbps in 0.000016 sec
> 
> Dima

When I mentioned about latency, the measurement is from
end-to-end (i.e. from app to app) but not just the
switching or port to port latencies.

With IB, I have seen the best numbers ranging from
5 to 7 us and which is far better than ethernet today 
(15 to 35us) with the network we have. I am not
denyig the fact that ethernet is trying to close the 
gap here but IB has got a relative advantage now.

Good to see you have got 5us in one case but what were
the switch and adapter latencies in this case.

Thanks
Venkat
