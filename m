From: Martin Tessun <tessun+Majordomo.Linux-Kernel.bcm43xx-xUmxicX565+Z9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Subject: Re: Machine hard lock
Date: Thu, 22 Dec 2005 18:49:04 +0100
Message-ID: <43AAE710.90502@mtessun.dyndns.org>
References: <20051222075903.3E196429EA9@mognix.dark-green.com>	 <43AAD978.2050303@mtessun.dyndns.org> <1135271149.8765.0.camel@localhost>
Reply-To: martin.tessun-xUmxicX565+Z9vWoFJJngh2eb7JE58TQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
In-Reply-To: <1135271149.8765.0.camel@localhost>
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

Johannes Berg wrote:
> On Thu, 2005-12-22 at 17:51 +0100, Martin Tessun wrote:
> 
>> At least you get them inserted ;) When I try to modprobe rate_control I 
>> get the following:
> 
> insmod 80211 first.
> 
> johannes

No, this ist not the problem.
When inserting 80211 I get the same message;

kernel: 80211: ieee80211_tx_packet_data is bigger than the skb->cb (48 > 
40)

And *this* is the real problem. The two structs don't match somehow.

Regards,
Martin
