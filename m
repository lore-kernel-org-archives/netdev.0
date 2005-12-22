From: Martin Tessun <tessun+Majordomo.Linux-Kernel.bcm43xx-xUmxicX565+Z9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Subject: Re: Machine hard lock
Date: Thu, 22 Dec 2005 17:51:04 +0100
Message-ID: <43AAD978.2050303@mtessun.dyndns.org>
References: <20051222075903.3E196429EA9@mognix.dark-green.com>
Reply-To: martin.tessun-xUmxicX565+Z9vWoFJJngh2eb7JE58TQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
In-Reply-To: <20051222075903.3E196429EA9-LloE6OrRT0E/VVZAJlljfpowlv4uC7bZ@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

hostmaster-uTGiPWHMmZuzZXS1Dc/lvw@public.gmane.org wrote:
> The combination of the latest devicescape stack ( 051221 )
> and latest dscape branch makes my Powerbook hard lock after 
> rmmod the kernel modules and stopping wpa_supplicant.
> 
> Basicly i do the following before it hard locks :
> 
> rmmod bcm43xx
> killall wpa_supplicant 2>/dev/null
> rmmod rate_control
> rmmod 80211

At least you get them inserted ;) When I try to modprobe rate_control I 
get the following:

Dec 22 15:27:48 kirk kernel: 80211: module license 'unspecified' taints 
kernel.
---> This line
Dec 22 15:27:48 kirk kernel: 80211: ieee80211_tx_packet_data is bigger 
than the skb->cb (48 > 40)
---> This line
Dec 22 15:27:48 kirk kernel: rate_control: Unknown symbol 
ieee80211_rate_control_unregister
Dec 22 15:27:48 kirk kernel: rate_control: Unknown symbol sta_info_release
Dec 22 15:27:48 kirk kernel: rate_control: Unknown symbol 
ieee80211_rate_control_register
Dec 22 15:27:48 kirk kernel: rate_control: Unknown symbol sta_info_get

Most probably caused by my 64-bit-kernel. I have to dig into that.

Nevertheless, I would address this sort of hangup to jbenc and probably 
jgarzik on linux-kernel (or better netdev).

Regards,
Martin
