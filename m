From: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: Proper ctrlmode handling for CAN
	devices
Date: Thu, 14 Jan 2010 15:53:46 +0100
Message-ID: <cabda6421001140653p296f4481oed1a1c731325961a@mail.gmail.com>
References: <1263403629-18827-1-git-send-email-chripell@fsfe.org>
	<4B4E2567.8060907@grandegger.com>
	<cabda6421001140618w2fb4e20fk680f8f01ff827e66@mail.gmail.com>
	<4B4F2C01.5000007@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B4F2C01.5000007-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2010 at 3:36 PM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wrote:
>
> I see. I really don't like the extra callback. Currently, it seems
> overkill to me. In principle, we could also do some checks in the device
> open function, if needed.
>

ack, I'll prepare a v2 patch soon.

>
> I found some links on that subject. Obviously, there is ENOTSUP and
> EOPNOTSUPP in the glibc, which are equal, but no ENOTSUPP. I tend to
> replace ENOTSUPP with EOPNOTSUPP, EINVAL or ENOSYS, what ever is more
> appropriate. Do you feel that EINVAL is more appropriate for the case above?
>

I'm perfectly ok with EOPNOTSUPP as you suggested.

-- 
Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
