From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Mon, 28 Nov 2011 16:10:03 +0100
Message-ID: <4ED3A44B.8060907@grandegger.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE9@saturn3.aculab.com>
	<4ED3960F.4040508@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ED3960F.4040508-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On 11/28/2011 03:09 PM, Marc Kleine-Budde wrote:
> On 11/28/2011 03:03 PM, David Laight wrote:
>>>>> +	for (idx = 0; idx < MAXDEV; idx++) {
>>>> ARRAY_SIZE?
>>>
>>> Well, I think ARRAY_SIZE is useful to derive the number of 
>>> elements from a static array of the type:
>>>
>>>   static const int array[] = { 1, 2, 3, 4, }
>>>
>>> but not if its declared as:
>>>
>>>   static array[MAXDEV]:
>>>
>>> ... or have I missed something?
>>
>> Yes - if you use ARRAY_SIZE() then someone reading the code
>> doesn't need to find the array definition to ensure the loop
>> upper bound is correct.
> 
> Yep, that
> was my intention, too.

OK, I see, and as we are all just human beings ...

Wolfgang.
