From: Hubert Tonneau <hubert.tonneau@fullpliant.org>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Wed, 23 Feb 2005 21:54:47 GMT
Message-ID: <052RU7B12@server5.heliogroup.fr>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "'cliff white'" <cliffw@osdl.org>,
        "'Alexey Kuznetsov'" <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
        "'David S. Miller'" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@osdl.org>, "Injong Rhee" <rhee@eos.ncsu.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>
> An interesting test would be to repeat the slow case: 2.6.10-ac11 over 100Mbps
> 
> With first TCP Reno (old default).
> 	sysctl -w net.ipv4.tcp_bic=0

No change.

> then TCP Westwood.
> 	sysctl -w net.ipv4.tcp_bic=0
> 	sysctl -w net.ipv4.tcp_westwood=1

No change.

Now Linux 2.6.11-rc4 with Injong Rhee abc patch:

No change.

Looks like David S. Miller is right.
Now, what I still don't understand is, if it's PSH/ACK related, why does
the gigabit connected Mac works nicely whereas the 100 Mbps connected one
does not ?
