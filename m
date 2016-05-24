From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH 0/2 (linux-stable-4.5.y)] net: stmmac: MDIO fixes
Date: Tue, 24 May 2016 09:08:47 +0200
Message-ID: <5743FDFF.9000704@st.com>
References: <1464009463-23654-1-git-send-email-peppe.cavallaro@st.com> <20160523153619.GA30179@kroah.com>
Reply-To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <robin.murphy-5wv7dgnIgG8@public.gmane.org>,
        <marc.zyngier-5wv7dgnIgG8@public.gmane.org>, <afaerber-l3A5Bk7waGM@public.gmane.org>, <bert-phGP8mJ4Mqk@public.gmane.org>,
        <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDB4X24GTMHRBCH4R65AKGQESIEK32Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20160523153619.GA30179-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On 5/23/2016 5:36 PM, Greg KH wrote:
> On Mon, May 23, 2016 at 03:17:41PM +0200, Giuseppe Cavallaro wrote:
>> These patches port some recent fixes for linux-4.5.y stable branch.
>> They fix the MDIO settings trying to cover the all possible scenario
>> when the stmmac is connected to a real transceiver or a switch.
>>
>> These patches are needed for Kernel 4.5 where Lime2, BananaPi and Cubieboard2
>> show problems when use the stmmac:
>>
>> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=823493
>
> What are the git commit id for these patches in Linus's tree?

Commits are:

stmmac: fix MDIO settings

    a7657f128c279ae5796ab2ca7d04a7819f4259f0

and

Revert "stmmac: Fix 'eth0: No PHY found' regression"

    d7e944c8ddc0983640a9a32868fb217485d12ca2

Regards
Peppe

>
> thanks,
>
> greg k-h
>
>
