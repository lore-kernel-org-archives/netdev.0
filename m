From: "Dr. Peter Bieringer" <pb@bieringer.de>
Subject: (usagi-users 02412) IPsec 2.5.70-bk9 and FreeS/WAN 1.99 with algopatches 0.8.1rc2
 (in)compatible encryption methods
Date: Thu, 05 Jun 2003 15:07:36 +0200
Message-ID: <35410000.1054818456@klopffest.muc.aerasec.de>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <usagi-users-admin@linux-ipv6.org>
To: netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Content-Disposition: inline
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi again,

because I got no success, I've tried different encryption methods than 
3DES. And *suddenly* it began to work.

One side  : 2.5.70-bk9
Other side: FreeS/WAN 1.99 with algopatches 0.8.1rc2

Result:

AES
---
AES-128: working

AES-192: not working
AES-256: not working

FreeS/WAN:
112 "freeswan-racoon-tunnel" #14: STATE_QUICK_I1: initiate
003 "freeswan-racoon-tunnel" #14: ESP transform ESP_AES passed key_len=32 > 
16
032 "freeswan-racoon-tunnel" #14: STATE_QUICK_I1: internal error


3DES
----
Not working, no message


Blowfish
--------
blowfish-128: working

Other key lengths: not working NO_PROPOSAL_CHOSEN


Other algorithms: not tested at the moment


I'm very wondering why 3DES is incompatible in IPsec-SA modus, while 
working in IKE.

Can someone confirm and/or extend this compatibility test?

TIA,
	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
