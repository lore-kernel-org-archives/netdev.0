From: Hubert Tonneau <hubert.tonneau@fullpliant.org>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sun, 13 Feb 2005 10:52:35 GMT
Message-ID: <0528GVO12@server5.heliogroup.fr>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, rick.jones2@hp.com,
        shemminger@osdl.org, romieu@fr.zoreil.com, netdev@oss.sgi.com
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
>
> Exactly. That's why the next test should be with disabled TSO in 2.6.9.
> If too rare PSHs were a problem, it will show as the same disaster there.

After,
ethtool -K eth1 tso off
the result is unchanged on 2.6.9 (14 seconds for 105 MB).

After,
ethtool -K eth1 tso off
the result is also unchanged on 2.6.10-ac11 with no extra TCP patch (325 seconds).


Settings for eth1:
Supported ports: [ TP ]
Supported link modes:   10baseT/Half 10baseT/Full 
                        100baseT/Half 100baseT/Full 
                        1000baseT/Full 
Supports auto-negotiation: Yes
Advertised link modes:  10baseT/Half 10baseT/Full 
                        100baseT/Half 100baseT/Full 
                        1000baseT/Full 
Advertised auto-negotiation: Yes
Speed: 1000Mb/s
Duplex: Full
Port: Twisted Pair
PHYAD: 0
Transceiver: internal
Auto-negotiation: on
Supports Wake-on: umbg
Wake-on: g
Current message level: 0x00000007 (7)
Link detected: yes


PS:
Please sorry for the long delay I have to run tests, and the reason is that
it's a production server, so I cannot make tests in the middle of the day,
it's remote, so in order to switch the kernel, I have to upload the new one,
and then upload again the old one to switch back, and the best connection
I have these days is 30 Kbps modem connection. It will improve on monday since
I'll have a 128 Kbps ADSL connection.
