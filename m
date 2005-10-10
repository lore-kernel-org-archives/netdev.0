From: Roland Dreier <rolandd@cisco.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 13:58:03 -0700
Message-ID: <52irw5f5t0.fsf@cisco.com>
References: <1128672413.13948.326.camel@localhost> <52br20lsei.fsf@cisco.com>
	<1128738350.13945.369.camel@localhost> <521x2tgrim.fsf@cisco.com>
	<434ACC74.3020404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <434ACC74.3020404@hp.com> (Rick Jones's message of "Mon, 10 Oct
	2005 13:17:56 -0700")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Rick> Which rev of netperf are you using, and areyou using the
    Rick> "confidence intervals" options (-i, -I)?  for a long time,
    Rick> the linux-unique behaviour of returning the overhead bytes
    Rick> for SO_[SND|RCV]BUF and them being 2X what one gives in
    Rick> setsockopt() gave netperf some trouble - the socket buffer
    Rick> would double in size each iteration on a confidence interval
    Rick> run.  Later netperf versions (late 2.3, and 2.4.X) have a
    Rick> kludge for this.

I believe it's netperf 2.2.

I'm not using any confidence interval stuff.  However, the variation
is not between single runs of netperf -- if I do 5 runs of netperf in
a row, I get roughly the same number from each run.  For example, I
might see something like

    TCP STREAM TEST to 192.168.145.2 : histogram
    Recv   Send    Send
    Socket Socket  Message  Elapsed
    Size   Size    Size     Time     Throughput
    bytes  bytes   bytes    secs.    10^6bits/sec
    
     87380  16384  16384    10.00    3869.82
    
and then

    TCP STREAM TEST to 192.168.145.2 : histogram
    Recv   Send    Send
    Socket Socket  Message  Elapsed
    Size   Size    Size     Time     Throughput
    bytes  bytes   bytes    secs.    10^6bits/sec
    
     87380  16384  16384    10.00    3862.41

for two successive runs.  However, if I reboot the system into the
same kernel (ie everything set up exactly the same), the same
invocation of netperf might give

    TCP STREAM TEST to 192.168.145.2 : histogram
    Recv   Send    Send
    Socket Socket  Message  Elapsed
    Size   Size    Size     Time     Throughput
    bytes  bytes   bytes    secs.    10^6bits/sec
    
     87380  16384  16384    10.00    4389.20

    Rick> Are there large changes in service demand along with the
    Rick> large performance changes?

Not sure.  How do I have netperf report service demand?

 - R.
