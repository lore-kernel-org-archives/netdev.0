From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Mon, 10 Jan 2011 15:07:25 +0100
Message-ID: <4D2B129D.30908@grandegger.com>
References: <20110104150513.GA321@e-circ.dyndns.org>	<20110104150759.GB321@e-circ.dyndns.org>	<4D24DB2C.9040104@grandegger.com>	<20110110133112.GA324@e-circ.dyndns.org>
	<4D2B1245.9060303@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D2B1245.9060303-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On 01/10/2011 03:05 PM, Wolfgang Grandegger wrote:
> On 01/10/2011 02:31 PM, Kurt Van Dijck wrote:
>> Wolfgang,
>>
>> A few thoughts ...
>>
>> On Wed, Jan 05, 2011 at 09:57:16PM +0100, Wolfgang Grandegger wrote:
>>>>  
>>>>  obj-y				+= usb/
>>>> +obj-y				+= softing/
>>>
>>> Please use "obj-$(CONFIG_CAN_SOFTING)" here.
>> As I explained, softing does not depend on softing_cs or vice versa,
>> which makes "obj-$(CONFIG_CAN_SOFTING)" not right.
> 
> OK, another good reason to make softing_cs depend on CONFIG_CAN_SOFTING.
> Does it make sense to compile softing_cs without CONFIG_CAN_SOFTING for
> the *real* user?
> 
> ...
> 
>>>> +	priv->can.ctrlmode_supported =
>>>> +		CAN_CTRLMODE_3_SAMPLES;/* | CAN_CTRLMODE_BERR_REPORTING */;
>>>
>>> Hm, any chance to support CAN_CTRLMODE_BERR_REPORTING? If not, please
>>> remove the comment.
>>
>> I think I better try to write it properly without, and add error reporting
>> later, after serious testing of the error reporting on a softing card.
> 
> OK, then just cleanup properly.
> 
>> The primary goal now is get this driver in mainline kernel since PCMCIA
>> has been changing recently, and I found it hard to keep up. So, first things
>> first ...
> 
> Fine for me. You can then add my:
> 
> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Is there a mailing list for the PCMCIA interface? If yes, please add it
to the CC as well.

Wolfgang.
