From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/4] can: cc770: add
 driver core for the Bosch CC770 and Intel AN82527
Date: Tue, 29 Nov 2011 10:20:13 +0100
Message-ID: <4ED4A3CD.4060908@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-2-git-send-email-wg@grandegger.com>
	<4ED3704D.5020903@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ED3704D.5020903-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On 11/28/2011 12:28 PM, Marc Kleine-Budde wrote:
> On 11/25/2011 10:43 AM, Wolfgang Grandegger wrote:
>> Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
>> ---
>>  drivers/net/can/Kconfig            |    2 +
>>  drivers/net/can/Makefile           |    1 +
>>  drivers/net/can/cc770/Kconfig      |    3 +
>>  drivers/net/can/cc770/Makefile     |    7 +
>>  drivers/net/can/cc770/cc770.c      |  895 ++++++++++++++++++++++++++++++++++++
>>  drivers/net/can/cc770/cc770.h      |  234 ++++++++++
>>  include/linux/can/platform/cc770.h |   33 ++
>>  7 files changed, 1175 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/net/can/cc770/Kconfig
>>  create mode 100644 drivers/net/can/cc770/Makefile
>>  create mode 100644 drivers/net/can/cc770/cc770.c
>>  create mode 100644 drivers/net/can/cc770/cc770.h
>>  create mode 100644 include/linux/can/platform/cc770.h
> 
> I don't know the hardware, but the code looks good to me, some comments:
> - The driver doesn't use NAPI, can this be added
> - The rx-handlers have a while(1) loop
>   For NAPI you have to add accounting, for the non NAPI case it would
>   be good, too.
> - I think you can move a large number of lines from the .h file into
>   the driver. Code that's not used in the different binding drivers.
> 
> More comments inline (mostly nitpicking)

I just sent out v4. For the sake of readability, I finally did not move
most of the head definitions in cc770.h into cc770.c and used the
variable name "o" consistently for the message object index (instead of
using "i").

Wolfgang.
