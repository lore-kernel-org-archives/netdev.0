From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: bcm43xx: "transmit timed out" and apparent hang with "preemptible
 periodic work" patches
Date: Thu, 29 Jun 2006 11:16:05 -0500
Message-ID: <44A3FCC5.1070305@lwfinger.net>
References: <87ac80ps5o.fsf@briny.internal.ondioline.org> <200606291707.55172.mb@bu3sch.de> <44A3F052.7030905@lwfinger.net> <200606291731.50598.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200606291731.50598.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

Michael Buesch wrote:
> On Thursday 29 June 2006 17:22, Larry Finger wrote:
>> Jun 29 01:22:08 larrylap kernel: bcm43xx: Controller restarted
>> Jun 29 01:23:08 larrylap kernel: bcm43xx: ASSERTION FAILED (channel >= 1 && channel <= 14) at: 
>> drivers/net/wireless/bcm43xx/bcm43xx_radio.c:79:channel2freq_bg()
> 
> WTF is that???
> How is that possible to happen?
> Are you sure you have an unmodified tree?

No, the tree is modified. It appears that something has messed up the bcm->ieee data. I am currently 
in the process of re basing my copy of Linville's tree and will try with an unmodified version.

Larry
