From: "Dr. Peter Bieringer" <pb@bieringer.de>
Subject: (usagi-users 02415) IPsec 2.5.70-bk9 and Check Point VPN-1 NG FP4 RC
Date: Thu, 05 Jun 2003 16:20:38 +0200
Message-ID: <3555172.1054830038@[10.3.62.6]>
References: <35410000.1054818456@klopffest.muc.aerasec.de>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: netdev@oss.sgi.com
In-Reply-To: <35410000.1054818456@klopffest.muc.aerasec.de>
Content-Disposition: inline
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi,

Here are some results (tunnel mode only tested, auth=SHA1):

DES    : ok
3DES   : ok
AES-128: ok
AES-192: not supported by CP VPN-1
AES-256: ok
CAST*  : not supported by used Linux kernel

BTW: be warned, not using RHL's ipsec-tools from rawhide...looks like the 
racoon isn't compiled in a proper environment :-( it doesn't support DES 
and causes trouble on 3DES *grmml*).

	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
