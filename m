From: Boniforti Flavio <boniforti@provincia.verbania.it>
Subject: Bonding on Linux: some questions.
Date: Wed, 18 Aug 2004 10:54:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4123194B.9090905@provincia.verbania.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!
I don't know if I'm talking to the right person, if it's not the case, 
please redirect me to the right one.
So, here we go.
I first would like to understand some things about bonding, which I 
can't find documented anywhere.
a) Is bonding in some way dependent on the setup of the switch to which 
I connect my Linux box? I mean: after I set up bonding on my Linux box, 
do I also have to do some configuration on the switch? I'm asking this 
because I read something about "trunking" in relation to bonding, but I 
didn't get the point at all.
b) How is the actual procedure of the bonding activation? As far as I 
understand it, bond0 should go up, then "ifenslave" the other (two in my 
case) ethX interfaces. The MAC address of bond0 should be the same of 
the first slave, while the second slave gets its MAC address also set to 
the one of the bond0 interface.

I hope somebody will answer me and help me in getting things to work 
correctly. Actually it seems that bonding is working on my system, 
though I have some doubts because:
a) eth1 (second slave) has its own MAC address, not bond0 one's;
b) if disconnecting eth1, network still works, but if disconnecting 
eth0, eth1 is actually set as active interface but no network activity 
is possible.

Thank you very much in advance.

Regards,
-- 
-----------------------------------
Boniforti Flavio
Provincia del Verbano-Cusio-Ossola
Ufficio Informatica

Tecnoparco del Lago Maggiore
Via dell'Industria, 25
28924 Verbania
-----------------------------------
