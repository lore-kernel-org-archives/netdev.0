From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCHv2 3/5] net: rfkill: gpio: remove gpio names
Date: Fri, 7 Mar 2014 11:41:11 +0800
Message-ID: <CACRpkdaYuZ5bXo7djOv04oyHPAFbO=pKfR7L7UBY+kZqZUHfmQ@mail.gmail.com>
References: <1393330950-7283-1-git-send-email-heikki.krogerus@linux.intel.com>
	<1393330950-7283-4-git-send-email-heikki.krogerus@linux.intel.com>
	<530D218E.9010007@wwwdotorg.org>
	<CACRpkdZF4-rWs1WkOp3t0x77fgSCE71E=wdrxiDuGZ8eBu_p_Q@mail.gmail.com>
	<53168976.7000008@wwwdotorg.org>
	<CACRpkdYfQoDmPX0He4J2Sn2wgQn2hHoHyPqnStLRVqrvi=M+-w@mail.gmail.com>
	<53169304.9080002@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Chen-Yu Tsai <wens@csie.org>,
	Rhyland Klein <rklein@nvidia.com>,
	Marc Dietrich <marvin24@gmx.de>, Arnd Bergmann <arnd@arndb.de>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53169304.9080002@wwwdotorg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 5, 2014 at 10:59 AM, Stephen Warren <swarren@wwwdotorg.org> wrote:
> On 03/04/2014 07:37 PM, Linus Walleij wrote:
>> On Wed, Mar 5, 2014 at 10:18 AM, Stephen Warren <swarren@wwwdotorg.org> wrote:
>>> On 03/04/2014 06:43 PM, Linus Walleij wrote:
>>
>>>> If I understand the situation correctly it's like ACPI does not have named
>>>> GPIOs so keeping specifying this in DT GPIO bindings is counter-productive
>>>> to the work of abstracting the access to GPIO handlers so that drivers
>>>> need not know whether ACPI or DT is used for describing the hardware.
>>>
>>> For devices that already have both ACPI and DT bindings, we can't
>>> pretend they can be the same; they are already potentially different. We
>>> simply need to parse DT and ACPI differently, since that's the sway
>>> their bindings are defined.
>>>
>>> For any devices that don't have both ACPI and DT bindings, I agree we
>>> should certainly strive to make any new bindings aligned so we don't
>>> have to deal with this for them.
>>>
>>> However, we can't change the past.
>>
>> Yeah, right, so for this very driver there are no bindings defined (yet)
>> and the only device tree I can find referencing it is the Tegra20-paz00
>> and it just use gpios = <>;
>>
>> So in this case I think this patch is the right way forward, but I admit
>> I'm really uncertain in the general case.
>
> If there are no bindings defined at all yet, then we can define both DT
> and ACPI bindings to use name-based GPIOs. Index-based lookups aren't a
> good way forward.

After Mark clarifying that ACPI is going to have named GPIOs I'm
totally aligned on this, so OK!

Yours,
Linus Walleij
