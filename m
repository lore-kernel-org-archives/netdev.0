From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 16:37:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927163751.274f6071.davem@davemloft.net>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
	<Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
	<20040927160411.22b44f48.davem@davemloft.net>
	<20040927232554.GB15825@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040927232554.GB15825@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 01:25:55 +0200
Andi Kleen <ak@suse.de> wrote:

> Unfortunately not - with the patch applied I still get 27MB/s

And without TSO you get?  How exactly are you running netperf
and are you going through a switch?  I want to reproduce your
test case exactly here although using tg3 instead of e1000 :)

> Looking at the tcpdump the ack clock goes completely out of sync,
> the ratio is 4 packets per ack. The sender seems to send packets
> faster than the target can ack them. It eventually stops for a 
> short time until it gets the ack

Hmmm, thanks for the trace.
