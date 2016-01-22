From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Fri, 22 Jan 2016 10:26:03 +0100
Message-ID: <56A1F5AB.6090606@gmail.com>
References: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
 <20160114164418.GD19773@lunn.ch>
 <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <56997951.90304@gmail.com> <5699B211.5070602@gmail.com>
 <VI1PR04MB16645A2F24DB515D86136BE2E8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <569C9CD2.10301@gmail.com>
 <VI1PR04MB1664AB0E483F01F1641059FFE8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20160118151500.GD923@lunn.ch>
 <VI1PR04MB1664DFBC53F08C5CE7EBF22AE8C10@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20160121211250.GK9991@lunn.ch>
 <VI1PR04MB1664BAFB4EE494CB14830BCCE8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Shaohui Xie <shaohui.xie-3arQi8VN3Tc@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <VI1PR04MB1664BAFB4EE494CB14830BCCE8C40-mr6QIVyDiCHTAO9RNConP89NdZoXdze2vxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 22.01.2016 09:15, Shaohui Xie wrote:
> _______________________________________
> From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
> Sent: Friday, January 22, 2016 5:12 AM
> To: Shaohui Xie
> Cc: Sebastian Hesselbarth; Florian Fainelli; shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Shaohui Xie
> Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
>
> On Tue, Jan 19, 2016 at 05:00:35AM +0000, Shaohui Xie wrote:
>>> -----Original Message-----
>>> From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
>>> Sent: Monday, January 18, 2016 11:15 PM
>>> To: Shaohui Xie
>>> Cc: Sebastian Hesselbarth; Florian Fainelli; shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org;
>>> devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linuxppc-
>>> dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Shaohui Xie
>>> Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
>>>
>>>> [S.H] the fsl backplane, e.g. 10GBASE-KR, needs software to handle
>>>> link training, It's to train link partner, and trained by link partner
>>> parallel.
>>>>
>>>> But if media type is not copper, e.g. optical module, we won't need this.
>>>
>>> So what we actually need to know is copper vs fibre?
>
>> Copper is not enough to indicate backplane, since backplane is
>> always copper, but copper is not always backplane.
>
>> O.K, lets try again....
>
> [S.H]Seems I did not get your point, Sorry for the inconvenient.
>
>> If it is copper backplane you need to perform training.
>
>> Looking at the driver probe function, it is either 1000BASE-KX, no
>> training needed, or else it is 10GBASE-RK and training is needed.
>
>> Looking at fsl_backplane_config_aneg() you expect phydev->speed to be
>> set, and from the speed you then kick of either KR autoneg or KX
>> autoneg. Could you also start the training at this point? Use the
>> speed to indicate if training is needed?
>
>   [S.H]The training cannot be started at this point, yet, because it's based on
> autoneg result, only when both sides autoneg-ed to 10G-KR, then to start
> the training.

Shaohui,

look, we want you to convince us why to have a generic backplane
property in the phy binding. You had a bad start by adding new
property values to a property that does not relate to your use
case at all. Your job now really is to give strong reasons _why_
and _what_ a phy driver needs to know about the backplane setup.

Your first approach was to add "10gbase-rk" or "40gbase-foo" but
now you tell us about ANEG. Of what use is the information given
by the property when ANEG tells you something different? E.g.
consider the property tells you "10g-something" but ANEG gives
you "40g"; does the property add any value to your training
decision now?

> Besides the driver, generally speaking, "copper + speed" is not enough to indicate
> it's backplane, for ex. "copper + 1000" does not mean it has to be 1000BASE-KX,
> it could be SGMII, hence cannot use KX autoneg.

So, is it copper + speed + backplane? or speed + backplane? And out of
the set of required input, is there anything your _cannot_ determine
from other things, e.g. ANEG?

If it is backplane only, would a boolean property ("backplane-mode")
be enough for the training decision?

> If putting backplane property to phy.txt is not good, I can put it to fsl specific
> binding, like the second patch 2/3 did.

You seem to see vendor specific properties as a place to dump all your
waste you don't want to think about. You fail to give good reasons what
is so special about the backplane setup and now you are telling us that
it is even fsl-specific?

Sebastian

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
