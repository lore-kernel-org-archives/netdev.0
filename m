From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 21 Dec 2010 20:27:19 +0100
Message-ID: <4D10FF97.1070703@grandegger.com>
References: <1292407130-19791-1-git-send-email-bhupesh.sharma@st.com>	<4D0BD454.3060503@grandegger.com>	<D5ECB3C7A6F99444980976A8C6D896384DEAE47E1A@EAPEX1MAIL1.st.com>	<4D0FBEF6.8020207@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAE481B6@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEAE481B6-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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

Hi Bhupesh,

On 12/21/2010 05:48 AM, Bhupesh SHARMA wrote:
> Hi Wolfgang,
...
>> In the meantime I compared the CAN chapter of the PCH manual with the
>> C_CAN manual. The paragraphs I checked are *identical*. This makes
>> clear, that the "pch_can" is a clone of the  C_CAN CAN controller, with
>> a few extensions, though. Therefore it would make sense, to implement a
>> bus sensitive interface like for the SJA1000 allowing to handle both
>> CAN
>> controllers with one driver sooner than later. Therefore, could you
>> please implement:
>>
>>   drivers/net/can/c_can/c_can.c
>>                        /c_can_platform.c
>>
>> Then an interface to the PCI based PCH CAN controller could be added
>> easily, e.g. as "pch_pci.c". You already had something similar in your
>> RFC version of the patch, IIRC.
> 
> This was the approach I initially proposed in my RFC V1 patch :)
> But unfortunately we could not agree to it.

I know. But at that time I was not aware of any other bus used for the
C_CAN controller.

> So, please let me reiterate what I understood and what was present
> in RFC version of the patch. Please add your comments/views:
> 
>         - drivers/net/can/c_can/c_can.c (similar on lines of sja1000.c)
>         i.e. a)no *probe* / *remove* functions here,
>              b)register read/write implemented here.
> 
>         - drivers/net/can/c_can/c_can_platform.c (similar on lines of sja1000_platform.c)
>         i.e. *probe* / *remove* implemented here,

Yes, that's what I'm thinking about.

> Marc and Tomoya can also add their suggestions so that I can finalize V3 a.s.a.p.

That would be nice, indeed. Also have a look to Tomoya's PCH driver,
which also looks very good in the meantime.

Wolfgang.
