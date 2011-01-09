From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Sun, 09 Jan 2011 15:40:54 +0100
Message-ID: <4D29C8F6.5030806@grandegger.com>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>	<20110106.113356.102556872.davem@davemloft.net>
	<4D261AAA.5030005@grandegger.com> <4D261BA4.2020003@pengutronix.de>
	<4D262158.4030301@grandegger.com> <4D299583.10909@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D299583.10909-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

On 01/09/2011 12:01 PM, Oliver Hartkopp wrote:
> On 06.01.2011 21:08, Wolfgang Grandegger wrote:
>> Hi Marc,
>>
>> On 01/06/2011 08:44 PM, Marc Kleine-Budde wrote:
> 
>>> If this driver will be merged, we'll have two drivers for the same can
>>> core in the tree. The other one is the pch_can. What do you think should
>>> be the mid term perspective for ccan based hardware?
>>
>> Yes, I know. Unfortunately, we did realize rather late the the PCH
>> controller is a C_CAN clone and the OKI/Intel ppls did not tell us
>> either. Therefore I asked Bhupesh to provide a SJA1000-a-like interface
>> for the C_CAN, which would allow us to provide an alternative PCI driver
>> "pch_pci.c" for the PCH. If that driver works well on the PCH hardware
>> as well, we should merge the best of both, if necessary, and then
>> finally remove the pch_can driver. Would that be a reasonable proposal.
> 
> At least for me this looks great. The idea to have a similar approach as we
> successfully implemented for the sja1000 will solve future hardware
> implementations based on the ccan controller core.

A common driver for c_can based devices will stabilize more quickly and
does also especially reduce the maintanance effort significantly.

> BTW. for the next submission of Bhupeshs patchset, i would propose to name the
> driver 'ccan' instead of 'c_can', so that we have a
> 
>     linux/drivers/net/can/ccan/...
> 
> path.

You are late ;-). Bosch named the controller *C_CAN* and therefore I
asked Bhupesh some time ago to change the file name and variable name
prefix from ccan to c_can.

> Checking directory names in linux/drivers with
> 
>     find . -type d | grep '_'
> 
> driver names with underscores are pretty unusual and mostly selected without
> fortune:
> 
> ./staging/olpc_dcon
> ./staging/wlags49_h2
> ./staging/wlags49_h2/man
> ./staging/serqt_usb2
> ./staging/intel_sst
> ./staging/quatech_usb2
> ./staging/asus_oled
> ./staging/wlags49_h25
> ./staging/ath6kl/hif/sdio/linux_sdio             <- Ugh!
> ./staging/ath6kl/hif/sdio/linux_sdio/src
> ./staging/ath6kl/hif/sdio/linux_sdio/include
> ./net/pch_gbe
> ./net/fs_enet
> ./net/wireless/libertas_tf
> ./net/ibm_newemacds
> 
> For that reason i would prefer 'ccan' to name this driver core.

Well, not really a strong argument. But well, if other people do
*prefer* ccan I would not object against it. Bhupesh, what's your opinion.

Wolfgang.
