From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: can: expected receive behavior broken
Date: Thu, 29 Jul 2010 13:16:46 +0200
Message-ID: <4C51631E.4000708@hartkopp.net>
References: <201007280956.38957.matthias.fuchs@esd.eu>
	<4C4FE7AC.4010806@grandegger.com>
	<201007281023.25039.matthias.fuchs@esd.eu>
	<4C514BAE.4070201@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C514BAE.4070201-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

On 29.07.2010 11:36, Oliver Hartkopp wrote:

> Invoking tst-rcv-own-msgs produces this output, which is far away from the
> correct (wanted) output seen in the commit message below.
> 
> sockopt default
>  s : 0
>  t : 0
>  timeout
> sockopt - -
>  timeout
> sockopt - R
>  timeout
> sockopt L -
>  s : 3
>  t : 3
>  timeout
> sockopt L R
>  s : 4
>  t : 4
>  timeout
> done.
> 
> I'll check that with the latest linux-2.6 (after rebooting :-)

Grr - it is also broken in 2.6.34-rc7-05126-g278554b ...

I'll go and hunt the bad commit in 2.6.34 and will fix it.

Tnx & regards,
Oliver


> It needs a vcan0 virtual CAN network interface and should produce an output
> like this, when invoked:
> 
> sockopt default
>  t : 0
>  timeout
> sockopt - -
>  timeout
> sockopt - R
>  timeout
> sockopt L -
>  t : 3
>  timeout
> sockopt L R
>  s : 4
>  t : 4
>  timeout
> done.
> 
