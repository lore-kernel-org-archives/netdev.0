From: Pekka Savola <pekkas@netcore.fi>
Subject: v6-in-v4 IPsec and NAT traversal
Date: Sat, 13 Mar 2004 11:43:04 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403131137400.22557-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm interested whether Linux IPsec implementations support:

 1) IPv6 payload inside IPv4 IPsec tunnel/transport?

 That is, when the intermediate network doesn't support IPv6, you
could do IPv6, secured, without first encapsulating in IPv6-over-IPv4
tunnel and then running IPv6 IPsec.

 2) NAT-traversal? (There are at least some patches in OpenSWAN, etc. 
for this).  This could be very handy combined with the above.

[[ 3) Some feasible key management method, such as certificates.  I 
think this exists, and doesn't require support in the kernel. ]]

I'm considering how viable this kind of NAT -traversal supporting
v6-in-v4 IPsec would be as an IPv6 tunneling/transition mechanism.

What's the status (implementations, planned or future) of these 
features?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
