From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] ARM: dts: Add the ethernet and ethernet PHY to the
 cygnus core DT.
Date: Tue, 25 Apr 2017 18:23:15 +0300
Message-ID: <44d0c48c-d80f-271e-0e19-ac87a53e2e53@cogentembedded.com>
References: <20170424215022.30382-1-eric@anholt.net>
 <20170424215022.30382-3-eric@anholt.net>
 <f870339f-2fa1-411d-5ce8-adbe8802d8a8@cogentembedded.com>
 <CAC3K-4qn5oCXvyMCkFESGqMHqHXGiNUW6wfRx2LUZ8qZ39qroQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Lunn <andrew@lunn.ch>,
 Florian Fainelli <f.fainelli@gmail.com>, Scott Branden <sbranden@broadcom.com>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Jon Mason <jonmason@broadcom.com>,
 Network Development <netdev@vger.kernel.org>,
 open list <linux-kernel@vger.kernel.org>, Eric Anholt <eric@anholt.net>,
 "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS"
 <devicetree@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
 BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
 Ray Jui <rjui@broadcom.com>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAC3K-4qn5oCXvyMCkFESGqMHqHXGiNUW6wfRx2LUZ8qZ39qroQ@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello!

On 04/25/2017 06:15 PM, Jon Mason wrote:

>>> Cygnus has a single amac controller connected to the B53 switch with 2
>>> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
>>> the external ethernet jacks.

[...]

>>> Signed-off-by: Eric Anholt <eric@anholt.net>
>>> ---
>>>  arch/arm/boot/dts/bcm-cygnus.dtsi      | 60
>>> ++++++++++++++++++++++++++++++++++
>>>  arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
>>>  2 files changed, 68 insertions(+)
>>>
>>> diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi
>>> b/arch/arm/boot/dts/bcm-cygnus.dtsi
>>> index 009f1346b817..318899df9972 100644
>>> --- a/arch/arm/boot/dts/bcm-cygnus.dtsi
>>> +++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
[...]
>>> @@ -295,6 +345,16 @@
>>>                         status = "disabled";
>>>                 };
>>>
>>> +               eth0: enet@18042000 {
>>> +                       compatible = "brcm,amac";
>>> +                       reg = <0x18042000 0x1000>,
>>> +                             <0x18110000 0x1000>;
>>> +                       reg-names = "amac_base", "idm_base";
>>
>>
>>    I don't think "_base" suffixes are necessary here.
>
> 100% necessary, per the driver.  See
> drivers/net/ethernet/broadcom/bgmac-platform.c

    I'd recommend to fix the driver/bindings then...

MBR, Sergei
