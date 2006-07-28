From: "Lamarque Souza" <lamarque_souza@hotmail.com>
Subject: tg3 module problem with suspend2
Date: Fri, 28 Jul 2006 02:13:08 +0000
Message-ID: <BAY112-F31BFE92D891589065C0D42F0590@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Cc: Suspend2-devel@lists.suspend2.net, mchan@broadcom.com
Return-path: <suspend2-devel-bounces@lists.suspend2.net>
To: netdev@vger.kernel.org
List-Unsubscribe: <http://lists.suspend2.net/mailman/listinfo/suspend2-devel>,
	<mailto:suspend2-devel-request@lists.suspend2.net?subject=unsubscribe>
List-Archive: <http://lists.suspend2.net/lurker/list/suspend2-devel.html>
List-Post: <mailto:suspend2-devel@lists.suspend2.net>
List-Help: <mailto:suspend2-devel-request@lists.suspend2.net?subject=help>
List-Subscribe: <http://lists.suspend2.net/mailman/listinfo/suspend2-devel>,
	<mailto:suspend2-devel-request@lists.suspend2.net?subject=subscribe>
Sender: suspend2-devel-bounces@lists.suspend2.net
Errors-To: suspend2-devel-bounces@lists.suspend2.net
List-Id: netdev.vger.kernel.org

Just to make you know. My notebook (Ferrari 4005wlmi, kernel2.6.17.3) uses 
the tg3 driver and has problems after resume from suspend2. The card is an 
Ethernet controller: Broadcom Corporation NetLink BCM5789 Gigabit Ethernet 
PCI Express (14e4:169d). The problem happens when I suspend with tg3 driver 
loaded. After resume, ifplugd detect link but does not renew the IP address. 
If I unconfigure the interface (/etc/init.d/net.eth0 stop in Gentoo) the 
mii-tool complaints with message "SIOCGMIIPHY on 'eth0' failed: Resource 
temporarily unavailable, no MII interfaces found". If I reaload the driver 
it works ok.

Do you have any idea why that happens?

-----
Lamarque V. Souza
http://www.geographicguide.com/brazil.htm
Linux User #57137 - http://counter.li.org/
