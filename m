From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 23:39:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930233925.022f3194.davem@redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	<20030928231842.GE1039@conectiva.com.br>
	<20030928232403.GX15338@fs.tum.de>
	<20030928233909.GG1039@conectiva.com.br>
	<20030929001439.GY15338@fs.tum.de>
	<20030929003229.GM1039@conectiva.com.br>
	<20030929221129.7689e088.davem@redhat.com>
	<20030930133729.GJ295@fs.tum.de>
	<20030930150430.GA2996@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, netdev@oss.sgi.com, pekkas@netcore.fi,
        lksctp-developers@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030930150430.GA2996@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Sep 2003 12:04:31 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> And just for the record, as a matter of taste I'd like to see all #ifdefs in
> structs to disappear, look at what I did to struct sock in 2.5 and look at
> struct sock (include/net/sock.h) in 2.4: no #ifdefs where there was a ton,

I totally agree with this.  It would make the structs that actually
get used smaller in fact.
