From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Fri, 24 Sep 2004 10:30:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924083007.GB25363@wotan.suse.de>
References: <20040921155835.18aee381.davem@davemloft.net> <20040922140000.GD27432@wotan.suse.de> <20040922111209.7887df53.davem@davemloft.net> <20040922195515.GA2619@wotan.suse.de> <c0a09e5c04092213126ba5f29d@mail.gmail.com> <20040922133906.7d57ef49.davem@davemloft.net> <20040922220628.GC2619@wotan.suse.de> <20040922152535.7bc81c8a.davem@davemloft.net> <20040922224732.GD2619@wotan.suse.de> <20040923161141.4ea9be4c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040923161141.4ea9be4c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Anyways, for testing, something like the patch below.  If things
> still stink a bit, try using a limit of "2" in this patch instead
> of "4".

Doesn't help unfortunately. Anything >= 2 gives 22MB/s or even below
(e.g. 3 gives 16MB/s). The only factor that works is 1, but that 
turns TSO effectively off, doesn't it? 

-Andi
