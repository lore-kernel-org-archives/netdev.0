From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 14:11:04 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
References: <4148991B.9050200@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: leonid.grossman@s2io.com, Linux Kernel <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <4148991B.9050200@pobox.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've never understood why people are so interested in off-loading
networking. Isn't that just a multi-processor system where you can't
use any of the network processor cycles for anything else? And, of
course, to be cheap, the network processor will be slower, and much
harder to debug and update software.

If the PCI bus is too slow, or MTU's too small, wouldn't
it be better to fix those directly and use a fast host processor that can
also do other things when not needed for networking? And why have
memory on a NIC that can't be used by other things?

Why don't we off-load filesystems to disks instead?  Or a graphics
card that implements X ? :-) I'd rather have shared system resources--
more flexible. :-)

                                        +-DLS
