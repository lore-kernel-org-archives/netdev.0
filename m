From: Hubert Tonneau <hubert.tonneau@fullpliant.org>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Tue, 22 Feb 2005 22:22:42 GMT
Message-ID: <052Q0TU11@server5.heliogroup.fr>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        Injong Rhee <rhee@eos.ncsu.edu>,
        "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@osdl.org>, cliff white <cliffw@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>
> This patch which was extracted from BIC TCP 1.1 compensates
> for systems (like MaxOSX) that don't ACK every other packet.
> It has no impact for normal transfers, but might help with problems
> with Mac like Hubert found.

No, it's even worse.

2.6.9 to 100 Mbps connected MacOSX: 15 seconds (for roughly 100 MB or data)
2.6.9 to gigabit connected MacOSX: 5 seconds
2.6.10-ac11 to 100 Mbps connected MacOSX: 325 seconds
2.6.10-ac11 to gigabit connected MacOSX: 5 seconds
2.6.10-ac11+BIC to 100 Mbps connected MacOSX: 620 seconds
2.6.10-ac11+BIC to gigabit connected MacOSX: 5 seconds
