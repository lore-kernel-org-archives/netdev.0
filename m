From: "Dr. Peter Bieringer" <pb@bieringer.de>
Subject: Re: (usagi-users 02412) IPsec 2.5.70-bk9 and FreeS/WAN 1.99 with
 algopatches 0.8.1rc2
Date: Thu, 05 Jun 2003 16:20:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3525719.1054830009@[10.3.62.6]>
References: <35410000.1054818456@klopffest.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <35410000.1054818456@klopffest.muc.aerasec.de>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ohoh, sorry for confusions, my racoon here was a little bit buggy...

...be warned, not using RHL's ipsec-tools from rawhide...looks like the 
racoon isn't compiled in a proper environment :-( it doesn't support DES 
and causes trouble on 3DES *grmml*).

The reported 3DES problem was solved now by using a fresh compiled one.

But the AES one still occurs.

> FreeS/WAN:
> 112 "freeswan-racoon-tunnel" #14: STATE_QUICK_I1: initiate
> 003 "freeswan-racoon-tunnel" #14: ESP transform ESP_AES passed key_len=32
> > 16 032 "freeswan-racoon-tunnel" #14: STATE_QUICK_I1: internal error

Or on 192 bits:

112 "freeswan-racoon-tunnel" #15: STATE_QUICK_I1: initiate
003 "freeswan-racoon-tunnel" #15: ESP transform ESP_AES passed key_len=24 > 
16
032 "freeswan-racoon-tunnel" #15: STATE_QUICK_I1: internal error

Strange, looks like racoon reports always AES key length 16*8, but in 
raccoon.conf was "aes 192" or "aes 256" specified.


	Peter, partially happy now
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
