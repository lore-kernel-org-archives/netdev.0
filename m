From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 2/4] net: systemport: use the new fixed PHY helpers
Date: Mon, 19 May 2014 16:31:26 -0700
Message-ID: <CAGVrzcYHQ7dXOi8z8W6d0u-bxLas8Za4O6n6_n1M6y+X9PH2Dw@mail.gmail.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
 <1400528625-32744-3-git-send-email-f.fainelli@gmail.com> <20140519221946.27dbad55@free-electrons.com>
 <CAGVrzcYwp6W7YgDmAbe3d+LEX105d+s1j2jV4zvAm52rWTt5rg@mail.gmail.com> <20140520000420.7039e1bc@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140520000420.7039e1bc-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-05-19 15:04 GMT-07:00 Thomas Petazzoni
<thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>:
> Dear Florian Fainelli,
>
> On Mon, 19 May 2014 14:52:57 -0700, Florian Fainelli wrote:
>
>> >> +     /* SYSTEMPORT uses the old 'fixed-link' 5-digit property which is
>> >> +      * deprecated, we need to register the fixed PHY using the Ethernet
>> >> +      * MAC node since we do not have a 'fixed-link' subnode.
>> >> +      */
>> >
>> > Actually even if you use the new fixed PHY DT binding, the DT node
>> > linked to the PHY is the Ethernet MAC node. This is because I didn't
>> > want to have a difference between how things are handled between the
>> > old and the new binding.
>>
>> Sure, I agree, and the comment still stands, I am just expressing it
>> that we are not looking for the 'fixed-link' subnode, but the
>> 'fixed-link' 5-digit property here. Would you want me to rephrase
>> that?
>
> What I found misleading in the comment is that you simply to imply that
> because you're not using the new DT binding for fixed-link, the DT node
> that is associated to the PHY is the Ethernet MAC.
>
> The truth is that the DT node associated to the fixed PHY is always the
> Ethernet MAC, regardless of whether you're using the old or the new DT
> binding.

Right, I will respin without this misleading comment and also to
address the formatting issue spotted by Sergei. Thanks!
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
