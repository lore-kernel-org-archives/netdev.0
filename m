From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: Re: [PATCH RFC 4/6] net: rfkill: gpio: add device
 tree support
Date: Wed, 29 Jan 2014 12:01:42 +0800
Message-ID: <CAGb2v65cipUXbL52adDTYLqVJB5gMoDjfWVFa6AYYp0EKvkS6g@mail.gmail.com>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
 <1389941251-32692-5-git-send-email-wens@csie.org> <20140127142400.GI3867@lukather>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBOX2UGLQKGQELXNO5YY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20140127142400.GI3867@lukather>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Jan 27, 2014 at 10:24 PM, Maxime Ripard
<maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
> Hi,
>
> On Fri, Jan 17, 2014 at 02:47:29PM +0800, Chen-Yu Tsai wrote:
>> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>> ---
>>  .../devicetree/bindings/rfkill/rfkill-gpio.txt     | 26 ++++++++++++++++++++++
>>  net/rfkill/rfkill-gpio.c                           | 23 +++++++++++++++++++
>>  2 files changed, 49 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
>>
>> diff --git a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
>> new file mode 100644
>> index 0000000..8a07ea4
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
>> @@ -0,0 +1,26 @@
>> +GPIO controlled RFKILL devices
>> +
>> +Required properties:
>> +- compatible : Must be "rfkill-gpio".
>> +- rfkill-name        : Name of RFKILL device
>> +- rfkill-type        : Type of RFKILL device: 1 for WiFi, 2 for BlueTooth
>> +- NAME_shutdown-gpios        : GPIO phandle to shutdown control
>> +                       (phandle must be the second)
>
> Can't it be handled by a regulator?
>
>> +- NAME_reset-gpios   : GPIO phandle to reset control
>
> And this one using the reset framework?

The driver is already used in platform device and ACPI fashions.
AFAIK, ACPI only passes the GPIO lines. Preferably the behavior
and requirements between the different usages remain the same.


Cheers
ChenYu
