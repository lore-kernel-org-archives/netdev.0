From: "Dr. Peter Bieringer " <pb@bieringer.de>
Subject: (usagi-users 02403) Compatibility problems IPsec 2.5.70 against FreeS/WAN 1.99
Date: Wed, 04 Jun 2003 16:53:50 +0200
Message-ID: <20030604145350.88F0D1387A@smtp2.aerasec.de>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Maillist USAGI-users" <usagi-users@linux-ipv6.org>
Return-path: <usagi-users-admin@linux-ipv6.org>
To: "Maillist netdev" <netdev@oss.sgi.com>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi, 

has anyone successful examples of configuration settings for 2.5.70 IPsec 
(racoon/SAD/SPD) and FreeS/WAN? 

I got no success between 2 hosts, neither in tunnel nor in transport mode. 

(racoon and pluto config looks like ok, the IPsec-SA was proper established, 
also both hosts send packets with related spi). 

In transport mode, the comment of Andreas came true that in the ESP packet 
an IP-in-IP tunnel packet is transported (sent from the 2.5.70-ipsec host): 

16:42:06.215546 [|ip]
0x0000   45                                             E
16:42:08.215348 [|ip]
0x0000   4500 0007 0004 40                              E.....@ 

Looks like FreeS/WAN don't like this. 

In tunnel mode, ipsec0 interface of FreeS/WAN drops all received packages by 
the 2.5.70-ipsec host (seen in ifconfig stat). 

On 2.5.70-ipsec side I currently don't know how to debug, but I only see the 
ESP packet on the interface, nothing decrpyted. 

Very strange at all... 

Any hints available how to let FreeS/WAN communicate with 2.5.70-ipsec? 

Thank you very much,
Peter 

-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/ 
