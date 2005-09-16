From: "Alaa Dalghan" <alaadalghan@hotmail.com>
Subject: Double Encryption
Date: Fri, 16 Sep 2005 13:36:04 +0000
Message-ID: <BAY106-F27CF4B237502C97B89C9B3AB910@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <linux-crypto-bounce@nl.linux.org>
To: users@openswan.org, linux-crypto@nl.linux.org, linux-kernel@vger.kernel.org, linux-net@vger.kernel.org, linux-security-module@mail.wirex.com, netdev@vger.kernel.org
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

Hi everyone,

I have an OpenSWAN (2.3.1) box accepting ipsec tunnels from wireless 
(802.11) clients equipped with Linux and Windows XP.
Wireless clients are using the openswan gateway to exchange data securely 
between each other, so there are no direct tunnels between client 
themselves.
The gateway is doing the routing job fine but there is a security gap when 
it has to decrypt data sent by a given client and then reencrypt it before 
sending it to the ultimate destination. It may be better not to expose the 
data in the clear at the gateway.

I know this can be solved by using double encryption (tunnel inside a  
tunnel), but, I wonder if  there is a better alternative?
I was thinking of using L2TP/IPSec tunnels instead of pure IPSec tunnels, 
and then, maybe I can use L2TP encryption to encrypt end-to-end and IPSec 
encryption to encrypt end-to-gateway. Would this work?

I appreciate any help and advices.

Alaadin

_________________________________________________________________
Don’t just search. Find. Check out the new MSN Search! 
http://search.msn.click-url.com/go/onm00200636ave/direct/01/


-
Linux-crypto:  cryptography in and on the Linux system
Archive:       http://mail.nl.linux.org/linux-crypto/
