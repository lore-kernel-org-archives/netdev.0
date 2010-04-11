From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Linux 2.6.34-rc3 + CAN build problem
Date: Sun, 11 Apr 2010 20:53:56 +0200
Message-ID: <4BC21AC4.8060403@hartkopp.net>
References: <1270892851.2093.32.camel@edumazet-laptop>	<4BC054AE.7040303@freemail.hu>	<4BC070E0.6070601@hartkopp.net>
	<20100410.155009.66184583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nm127-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100410.155009.66184583.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> Date: Sat, 10 Apr 2010 14:36:48 +0200
> 
>> So i wonder why Nemeth trapped into this problem ... probably an include file
>> mix-up?
> 
> Do you have CONFIG_DEBUG_STRICT_USER_COPY_CHECKS enabled in your
> kernel config?
> 
> That's the only way you get an actual failure of a build when
> the user copy size can't be proven to be in range by the
> compiler, otherwise it just warns.

No, indeed i do not have it set.

# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set

What would be the best approach to fix this build failure then?

By applying the patch thankfully provided by Eric?

Regards,
Oliver
