From: "David S. Miller" <davem@redhat.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Mon, 15 Sep 2003 01:17:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915011731.59056bfc.davem@redhat.com>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com>
	<3F652910.4090509@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ricardoz@us.ibm.com, hadi@cyberus.ca, greearb@candelatech.com,
   jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <3F652910.4090509@pacbell.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 14 Sep 2003 19:50:56 -0700
David Brownell <david-b@pacbell.net> wrote:

> Except ones where CONFIG_EMBEDDED, maybe?  Not everyone wants
> to spend that much memory, even when it's available...

Dropping the packet between the network stack and the driver
does waste memory for _LONGER_ periods of time.

When we drop, TCP still hangs onto the buffer, and we'll send
it again and again until it makes it and we get an ACK back
or the connection completely times out.
