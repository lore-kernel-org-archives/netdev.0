From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 19:44:54 +0200
Message-ID: <20050518174454.GD15391@postel.suug.ch>
References: <20050517.104947.112621738.davem@davemloft.net> <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050518004733.GG13748@postel.suug.ch> <20050518011632.GA27813@gondor.apana.org.au> <20050518013712.GH13748@postel.suug.ch> <428B6B72.5010407@hp.com> <20050518174010.GC15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <20050518174010.GC15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20050518174010.GC15391@postel.suug.ch> 2005-05-18 19:40
> In a perfect world without any randomly generated ids we could measure
> the absolute distance even without being aware of all ids, it might even
> be possible to try and differ between random and serial id sequences
> and optimize a bit there but in the end we have to find a good
> compromise for the random case anyway. Worth some experimentation I guess.

Wild thought: We could introduce a new ip option stating that the id
generator uses a serial approach which would give us the possibility
to measure the absolute distance and resolve this issue in a perfect
matter for everyone supporting this extension. ;->
