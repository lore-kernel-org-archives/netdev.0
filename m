From: "Alaa Dalghan" <alaadalghan@hotmail.com>
Subject: VPN server over windows XP
Date: Wed, 14 Sep 2005 20:18:20 +0000
Message-ID: <BAY106-F29965CB20274069D3A5BA5AB9F0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <linux-crypto-bounce@nl.linux.org>
To: linux-crypto@nl.linux.org, linux-kernel@vger.kernel.org, linux-net@vger.kernel.org, linux-security-module@mail.wirex.com, netdev@vger.kernel.org
Sender: linux-crypto-bounce@nl.linux.org
Errors-to: linux-crypto-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:linux-crypto-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:linux-crypto-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:linux-crypto@nl.linux.org>
List-archive: <http://mail.nl.linux.org/linux-crypto/>
List-Id: netdev.vger.kernel.org

hello everyone,

I am trying to setup a windows xp machine as a vpn server that accepts 
multiple ipsec tunnels from other windows xp machines.

My restrictions are the following:

1- I need to set the vpn server on windows XP (not windows 2000 server, nor 
2003, nor ISA server, etc.)

2- I need to use tunnel mode ipsec

3- The vpn server should accept MULTIPLE vpn tunnels.

The first problem I faced is that windows xp does not support ipsec tunnel 
mode between 2 xp machines. It only supports transport mode which is not 
what I want.
To overcome this lack of IP tunneling I tried to use the built-in tunneling 
capabilities such as PPTP and L2TP/ipsec, and it worked. But the problem 
here is that a windows xp can not accept more than ONE SINGLE incoming 
connection at a time, and I need multiple connections.

I think the solution could be one of the following:

1-Installing a third party FREE vpn server (or L2TP server) on windows XP. 
If you know one please tell me.

2-Importing some features from windows 2000 server or 2003 server (some 
executables or services or plugins that enable xp to run as a vpn server and 
accept multiple connections). If you know what to import please tell me.

3- Installing a pure IP tunneling solution on windows xp so that it can be 
combined with ipsec encryption to yield tunnel mode encryption.

I appreciate any help,

Alaadin

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today - it's FREE! 
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/


-
Linux-crypto:  cryptography in and on the Linux system
Archive:       http://mail.nl.linux.org/linux-crypto/
