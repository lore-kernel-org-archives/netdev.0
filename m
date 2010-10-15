From: Patrick Ringl <patrick_@freenet.de>
Subject: 2.6.36-rc7: net/bridge causes temporary network I/O lockups
Date: Sat, 16 Oct 2010 01:13:21 +0200
Message-ID: <4CB8E011.8050401@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

after I recently switched from 2.6.32 to 2.6.35 (and for testing to 
2.6.36-rc7) I had massive issues with temporarily occurring freezes 
regarding the whole network stack.
The freezes are occurring randomly and usually take 20-30 seconds until 
the system is responsive again (in addition locally thus with a screen 
and keyboard attached the system is still fully functional).

I noticed that this behavior only occurs once I have a bridge set up for 
KVM (with one local interface configured as port, fd and maxwait set to 
0). If I disable the bridge and configure the interfaces with an IP, 
things are back to normal and thus everything works fine.

The network hardware in question was an nforce onboard controller (using 
dethforce) and the 2nd interface I have the exact same issue with is a 
realtek using r8169.

So here it is: Could commit 573201f36fd9c7c6d5218cdcd9948cee700b277d ( 
partially disabling netpoll support) be the issue for the problem I am 
currently facing? If not, what could it be then?


Please CC to me since I am not subscribed! :-)



regards,
Patrick
