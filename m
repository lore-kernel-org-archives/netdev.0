From: Andrea G Forte <andreaf@cs.columbia.edu>
Subject: IP aliasing and IP change delay.
Date: Mon, 06 Dec 2004 19:28:04 -0500
Message-ID: <41B4F914.2070401@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,

I am new to this list but I hope you can help me.
I have been trying to use two different IP addresses on the same PCMCIA 
wireless card. For doing this I tried the classic
ifconfig wlan0:0 inet xxx.xxx.xxx.xxx
route ......
and I also tried
ip address add xxx.xxx.xxx.xxx dev wlan0

The problem is that after I issue the command, the IP is actually 
changed several hundred of milliseconds later, while if I do not create 
an alias and change the IP twice on the same interface (using ifconfig), 
then the change of IP is really fast, practically it changes starting 
from the packet following the command.
Anybody has some ideas why there is such a double behaviour if using 
wlan0 and wlan0:0 or using only wlan0??

Thank you very much for your help,
Andrea
