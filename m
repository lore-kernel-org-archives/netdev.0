From: Marc Herbert <marc.herbert@free.fr>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Wed, 2 Jun 2004 21:11:04 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405190110280.30653@fcat>
References: <OF817307D7.5FC78280-ON85256E98.004FDB43-86256E98.00500AA1@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ricardo C Gonzalez <ricardoz@us.ibm.com>
In-Reply-To: <OF817307D7.5FC78280-ON85256E98.004FDB43-86256E98.00500AA1@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 May 2004, Ricardo C Gonzalez wrote:

>       Are you considering the case of small packets?

Good point: I was not, because it adds some complexity :-/


> Many applications use
> lots of small packets.  Example is the volano benchmark.

Well... isn't that example a bit extreme, rather than representative=A0?


> You needs to look at throughput rates for small packets. A 1GB  etherne=
t
> can send something like 1.4 Million 64 byte packets per second.
>
> Let me know what you think.

I said in some previous message that, from the point of view of IP
"applications" in the very broad sense (i.e., including TCP) the
txqueuelen should ideally be defined in milliseconds, in order to give
an upper bound to latency. I reiterate that. So, for a given Ethernet
link _speed_, this would translates into an ideal definition of
txqueuelen in _bytes_ and not in _packets_. The current approximation
(in packets) seems to assume that people wishing to send a whole lot
of small packets are seldom, and can set the txqueuelen by themselves.
This seems sensible to me.
