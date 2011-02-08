From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: About bittiming calculation result
Date: Tue, 08 Feb 2011 08:57:14 +0100
Message-ID: <4D50F75A.5040700@grandegger.com>
References: <cover.1296818921.git.segoon@openwall.com><a6800dc8b0daed78256f98f52844cbbb48f4a76d.1296818921.git.segoon@openwall.com><20110204124233.GB334@e-circ.dyndns.org>	<20110204.130649.112613896.davem@davemloft.net>	<5009516791F146C49C73FAC57C437313@hacdom.okisemi.com>	<4D4FDEF9.2030305@grandegger.com>
	<4D501555.5000905@grandegger.com>
	<93C12206407640199DCDD3A89A333F13@hacdom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <93C12206407640199DCDD3A89A333F13-c0cKtqp5df7I9507bXv2FdBPR1lH4CV8@public.gmane.org>
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

Hi Tomoya,

On 02/08/2011 02:27 AM, Tomoya MORINAGA wrote:
> On Tuesday, February 08, 2011 12:53 AM,  Wolfgang Grandegger wrote:
> 
>> BTW, it's always possible to specify optimized bit-timing 
>> parameters directly, e.g. the following seem better:
>>
>>    800000     60  12    4    4   4   3  793650  0.8% 80.0% 81.0%  1.2%
>>
>> You could set these with:
>>
>>   $ ip link set can0 type can \
>>     tq 60 prop-seg 12 phase-seg1 4 phase-seg2 4 sjw 4
> 
> I can confirm 800K comms works well using the above.

Cool, I got these magic values from a CAN hardware expert.

> I wish Can-core could calculate like above.

Me too! I also got some indication on how to improve our algorithm in
case the bit-rate does not match. Hope to find some time soon to work
on this issue.

>>> seg1/seg2/sjw/prop_seg must be more than 1 ?
> BTW, according to EG20T PCH data sheet, 
> CAN bit-timing parameters(BRP, Prop_Seg, Phase_Seg1, Phase_Seg2, SJW) must not be set 0.

OK, then please provide a patch setting tseg1_min to 2.

Wolfgang.
