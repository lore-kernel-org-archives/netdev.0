From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2] candev: allow SJW user setting for bittiming
	calculation
Date: Fri, 23 Sep 2011 09:24:20 +0200
Message-ID: <4E7C3424.8030406@grandegger.com>
References: <4E7B0DE6.9020807@hartkopp.net> <4E7B331F.3070801@grandegger.com>
	<4E7B61C8.8020506@hartkopp.net> <4E7B7A30.4030707@grandegger.com>
	<4E7B8F63.6060108@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E7B8F63.6060108-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

Hi Oliver,

On 09/22/2011 09:41 PM, Oliver Hartkopp wrote:
> Hi Wolfgang,
> 
> i put Pavel and Andrey into CC, maybe they also have an opinion about this.
> I just talked to a specialist who told me, that a higher SJW is better - if

Then let us set it to 4 (maximum), by default. But other documents
recommend a value of 1.

> possible. And if an expert told me so and i had a simple config interface to
> fullfill it, it would be great for me ;-)

Anyway, if SJW does not depend on other bit-timing parameters and it
usually works fine with the kernel calculated parameters I would no
longer vote against this patch.

Wolfgang,
