From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 net-next] net: phy: Add LED mode driver for Microsemi PHYs.
Date: Tue, 21 Feb 2017 10:42:38 -0600
Message-ID: <CAL_JsqJLCe1O7Bv526zAY-s-R1DcnA2O0bpx48dTFGSgeu-Edw@mail.gmail.com>
References: <1486474826-29426-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20170215164540.eok7bnudfffzoyi4@rob-hp-laptop> <20170216090646.GA29082@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170216090646.GA29082-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2017 at 3:06 AM, Raju Lakkaraju
<Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org> wrote:
> Hi Rob,
>
> On Wed, Feb 15, 2017 at 10:45:40AM -0600, Rob Herring wrote:
>> EXTERNAL EMAIL
>>
>>
>> On Tue, Feb 07, 2017 at 07:10:26PM +0530, Raju Lakkaraju wrote:
>> > From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
>> >
>> > +                       Default value is VSC8531_LINK_1000_ACTIVITY (1).
>> > +- vsc8531,led-1-mode : LED mode. Specify how the LED[1] should behave.
>>
>> You failed to address my comment on v2. vsc8531 is not a vendor prefix.
>> Please fix in a new patch since David already applied it.
>>
>
> Accpeted my fault. i missed your comment.
> Do i need to change from  "vsc8531, led-0-mode" to "mscc, led-0-mode"
> Is this your suggestion?

Well, there shouldn't be a space there, but yess, mscc is the prefix.

Read my original comments. I also suggested combining this to a single property.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
