From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] ARM: at91/dt: sama5d3 xplained: add phy address for macb1
Date: Sat, 4 Apr 2015 14:45:48 +0200
Message-ID: <551FDCFC.4070806@atmel.com>
References: <1427792170-13162-1-git-send-email-nicolas.ferre@atmel.com>
 <551E52BC.3040702@atmel.com> <20150403205507.GH23023@localhost>
 <20150403215607.GS23023@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Boris BREZILLON <boris.brezillon@free-electrons.com>,
 Arnd Bergmann <arnd@arndb.de>, Kevin Hilman <khilman@kernel.org>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 Johan Hovold <johan@kernel.org>, ARM Maintainers <arm@kernel.org>,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org
To: Olof Johansson <olof@lixom.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20150403215607.GS23023@localhost>
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

Le 03/04/2015 23:56, Olof Johansson a =E9crit :
> On Fri, Apr 03, 2015 at 01:55:07PM -0700, Olof Johansson wrote:
>> On Fri, Apr 03, 2015 at 10:43:40AM +0200, Nicolas Ferre wrote:
>>> Le 31/03/2015 10:56, Nicolas Ferre a =E9crit :
>>>> After 57a38effa598 (net: phy: micrel: disable broadcast for KSZ8081/KS=
Z8091)
>>>> the macb1 interface refuses to work properly because it tries
>>>> to cling to address 0 which isn't able to communicate in broadcast with
>>>> the mac anymore. The micrel phy on the board is actually configured
>>>> to show up at address 1.
>>>> Adding the phy node and its real address fixes the issue.
>>>>
>>>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>>>> Cc: Johan Hovold <johan@kernel.org>
>>>> Cc: <stable@vger.kernel.org> #3.19
>>>> ---
>>>
>>> Arnd, Olof, Kevin,
>>>
>>> It seems late but, is it possible to queue this patch as a 4.0 fixes?
>>>
>>> Without it, the 10/100 Ethernet on sama5d3 doesn't work if it's not used
>>> by u-boot previously.
>>
>> Sure, resend it to arm@kernel.org.
>
> Nevermind, I ended up picking it up from the list. Applied.

Cool: thanks Olof!

Bye,

-- =

Nicolas Ferre
