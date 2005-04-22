From: Andi Kleen <ak@muc.de>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 13:36:56 +0200
Message-ID: <m1hdhzyrdz.fsf@muc.de>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20050419055535.GA12211@sgi.com> (Greg Banks's message of "Tue,
 19 Apr 2005 15:55:35 +1000")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Greg Banks <gnb@sgi.com> writes:
>
> An inordinate amount of CPU is being spent running around polling the
> device instead of dealing with the packets in IP, TCP and NFS land.
> By inordinate, we mean twice as much or more cpu% than a MIPS/Irix
> box with slower CPUs.

We have seen similar behaviour. With NAPI some benchmarks run
a lot slower than on a driver on the same hardware/NIC without NAPI.
This can be even observed with simple tests like netperf single stream
between two boxes.

There seems to be also some problems with bidirectional traffic, although
I have not fully tracked them down to NAPI yet.

There is definitely some problem in NAPI land ...

-Andi
