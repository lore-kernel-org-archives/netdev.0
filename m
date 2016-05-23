From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: 4.5.0 on sun7i-a20-olinuxino-lime2: libphy: PHY
 stmmac-0:ffffffff not found (regression from rc7)
Date: Mon, 23 May 2016 15:28:04 +0200
Message-ID: <57430564.9050305@st.com>
References: <56E9413D.9010902@a20.net>	<56E945FF.6080005@arm.com>	<56E94CF4.2060607@arm.com>	<56E95B57.1090100@suse.de>	<56E9776F.3070102@a20.net>	<56E99B0C.2070609@arm.com>	<56E9F2B8.1030605@a20.net>	<20160317075202.16b14ed6@arm.com>	<CAHsu+b-t_r93XKLJTUcin6xjhOrFVn3_60vwHkbRt3iHK28CbA@mail.gmail.com>	<573EC33D.2010209@arm.com>	<573EC77A.2000800@st.com>	<CAHsu+b9BrqBLdCpsPpetc_4_EaFVGBdDHtoeeCqqzsCG3Wpsig@mail.gmail.com>	<573EE8B4.1050701@arm.com>	<574082F9.7010702@a20.net> <20160522103056.2fa86293@arm.com>
Reply-To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Andre Heider <a.heider-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexandre Torgue
	<alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>,
        =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?=
	<afaerber-l3A5Bk7waGM@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>, Bert Lindner <bert-phGP8mJ4Mqk@public.gmane.org>
Return-path: <linux-sunxi+bncBDB4X24GTMHRB24KRS5AKGQEBNSOSJA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20160522103056.2fa86293-5wv7dgnIgG8@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hello

On 5/22/2016 11:30 AM, Marc Zyngier wrote:
> On Sat, 21 May 2016 17:47:05 +0200
> Bert Lindner <bert-phGP8mJ4Mqk@public.gmane.org> wrote:
>
>> Hi,
>>
>> On 2016-05-20 12:36, Marc Zyngier wrote:
>>> On 20/05/16 11:30, Andre Heider wrote:
>>>> Hi,
>>>>
>>>> On Fri, May 20, 2016 at 10:14 AM, Giuseppe CAVALLARO
>>>> <peppe.cavallaro-qxv4g6HH51o@public.gmane.org> wrote:
>>>>> On 5/20/2016 9:56 AM, Marc Zyngier wrote:
>>>>>>
>>>>>> On 20/05/16 06:44, Andre Heider wrote:
>>>>>>>
>>>>>>> Giuseppe, Alexandre, et al.,
>>>>>>>
>>>>>>> On Thu, Mar 17, 2016 at 8:52 AM, Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org=
>
>>>>>>> wrote:
>>>>>>>>
>>>>>>>> On Thu, 17 Mar 2016 00:56:40 +0100
>>>>>>>> Bert Lindner <bert-phGP8mJ4Mqk@public.gmane.org> wrote:
>>>>>>>>>
>>>>>>>>> On 2016-03-16 18:42, Marc Zyngier wrote:
>>>>>>>>>>
>>>>>>>>>> On 16/03/16 15:10, Bert Lindner wrote:
>>>>>>>>>>>
>>>>>>>>>>> On 2016-03-16 14:10, Andreas F=C3=A4rber wrote:
>>>>>>>>>>>>
>>>>>>>>>>>> Am 16.03.2016 um 13:09 schrieb Robin Murphy:
>>>>>>>>>>>>>
>>>>>>>>>>>>> On 16/03/16 11:39, Marc Zyngier wrote:
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> On 16/03/16 11:19, Bert Lindner wrote:
>>>>>>>
>>>>>>> ...
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> For the board sun7i-a20-olinuxino-lime2, there seems to be =
a
>>>>>>>>>>>>>>> problem
>>>>>>>>>>>>>>> with the eth0 PHY in mainline kernel 4.5.0 that developed s=
ince
>>>>>>>>>>>>>>> 4.5.0-rc7. Ethernet does not work, although eth0 is reporte=
d:
>>>>>>>
>>>>>>> ...
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> [    9.767125] NET: Registered protocol family 10
>>>>>>>>>>>>>>> [   10.357405] libphy: PHY stmmac-0:ffffffff not found
>>>>>>>>>>>>>>> [   10.362382] eth0: Could not attach to PHY
>>>>>>>>>>>>>>> [   10.366557] stmmac_open: Cannot attach to PHY (error: -1=
9)
>>>>>>>
>>>>>>> ...
>>>>>>>>>>>>
>>>>>>>>>>>> v4 fixes for 4.5 are here:
>>>>>>>>>>>>
>>>>>>>>>>>> https://patchwork.ozlabs.org/patch/598195/ (revert)
>>>>>>>>>>>> https://patchwork.ozlabs.org/patch/598196/
>>>>>>>
>>>>>>> ...
>>>>>>>>>>
>>>>>>>>>> Good to know, thanks. Could you also give the potential fix a go=
 (as
>>>>>>>>>> mentioned by Andreas)? Just to make sure that whatever gets merg=
ed
>>>>>>>>>> next
>>>>>>>>>> will actually fix the issue.
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> Yes sure, it took a while because I had to travel. Confirmed, the
>>>>>>>>> v4-for-4.5 fix works well for me, on sun7i-a20-olinuxino-lime2:
>>>>>>>>>
>>>>>>>>> root@lime2-079f:~# cat /proc/version
>>>>>>>>> Linux version 4.5.0-598195-598196-v4 (root@lime2-079f) (gcc versi=
on
>>>>>>>>> 4.9.1 (Ubuntu/Linaro 4.9.1-16ubuntu6) ) #1 SMP Wed Mar 16 16:44:2=
2 UTC
>>>>>>>>> 2016
>>>>>>>>>
>>>>>>>>> dmesg:
>>>>>>>>> [    8.245273] NET: Registered protocol family 10
>>>>>>>>> [    9.297406]  RX IPC Checksum Offload disabled
>>>>>>>>> [    9.297460]  No MAC Management Counters available
>>>>>>>>> [    9.297951] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>>>>>>>>> [   16.285658] sun7i-dwmac 1c50000.ethernet eth0: Link is Up -
>>>>>>>>> 1Gbps/Full - flow control rx/tx
>>>>>>>>> [   16.285798] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes =
ready
>>>>>>>>>
>>>>>>>>> The board is connected to my laptop rather than to a switch, so t=
hat
>>>>>>>>> might be where the flow control message comes from (not sure). An=
yway
>>>>>>>>> ethernet works.
>>>>>>>>
>>>>>>>>
>>>>>>>> Cool, many thanks for taking the time to test and report.
>>>>>>>>
>>>>>>>> Hopefully Giuseppe will get this merged quickly enough in mainline=
, and
>>>>>>>> it should then trickle into a 4.5-stable release (cc-ing stable on
>>>>>>>> these patches would probably be a good idea, BTW).
>>>>>>>
>>>>>>>
>>>>>>> stmmac is broken on at least Lime2, BananaPi and Cubieboard2 since
>>>>>>> v4.5 [0], including all five stable releases :(
>>>>>>
>>>>>>
>>>>>> All the A20 platforms are dead, actually.
>>>>>>
>>>>>>> The v4.5 patches quoted above are already +4 weeks old, could we
>>>>>>> please get them into stable?
>>>>>>
>>>>>>
>>>>>> For that, the maintainer would have needed to CC stable, which he
>>>>>> didn't. I'd expect someone who cares to send these patches to stable=
.
>>>>>> It'd be better if the maintainer would do it himself though.
>>>>>
>>>>>
>>>>> sure, I can send the patches to stable (sorry if I missed to add
>>>>> stable ML on CC).
>>>>>
>>>>> Andre, I have not clear if the train of patches actually fix the
>>>>> issue or if you need my support to fix something else. In that case
>>>>> I need some input for debugging (e.g. kernel log).
>>>>
>>>> Bert already confirmed that those two patches fixes stmmac on his
>>>> Lime2, so I assume that it fixes the issue for all A20 platforms.
>>>>
>>>>> let me know, is it enough to re-send the patches only?
>>>>
>>>> Just a resend with cc:stable :)
>>>
>>> Not quite. Please read Documentation/stable_kernel_rules.txt, and the
>>> section that concerns networking patches (and then consult
>>> Documentation/networking/netdev-FAQ.txt which has all the details).
>>
>> FWIW, recent 4.6-rc series and 4.6.0 have worked fine for me and the
>> lime2. Had not tried 4.5.x again.
>
> We've already established this. This is a 4.5-specific regression (both
> 4.4 and 4.6 are fine). One major issue is that Debian Stretch is
> currently shipping with 4.5, and upgrading to it results in a system
> without networking. Should this patch make it into stable, the fix would
> quickly percolate into distro kernels, and we could forget about it.

I have just ported and sent the patches to stable list.

   [PATCH 0/2 (linux-stable-4.5.y)] net: stmmac: MDIO fixes

Please, let me know if it is ok for you.

Peppe



> Thanks,
>
> 	M.
>

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
