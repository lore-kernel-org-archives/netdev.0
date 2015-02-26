From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Thu, 26 Feb 2015 09:57:17 -0800
Message-ID: <54EF5E7D.7060504@gmail.com>
References: <54ED017E.6000902@gmail.com> <20150225001534.GB15633@lunn.ch> <54ED19AB.7020003@gmail.com> <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com> <20150225140356.GB17992@lunn.ch> <CACna6ryQzXQn4Gxn701pXCU6MrZje+w-5B0htM+-PukMbq7ZFQ@mail.gmail.com> <20150225141945.GC17992@lunn.ch> <CACna6ryUgu3wmQGmU1EomY-CDpBfh2BN8_K+V-XD_3mj4txLDw@mail.gmail.com> <20150226151830.GD8806@lunn.ch> <CACna6rwVRB2q89EOKNK=5iQogE6_LBGUo1=M1ED0OaR7UqLAAg@mail.gmail.com> <20150226153605.GE8806@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>, Rafa?? Mi??ecki <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:38803 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253AbbBZR5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 12:57:40 -0500
Received: by padbj1 with SMTP id bj1so15697468pad.5
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 09:57:40 -0800 (PST)
In-Reply-To: <20150226153605.GE8806@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/02/15 07:36, Andrew Lunn wrote:
>> It doesn't really answer my question as I don't see functionality I'm
>> looking for in bcm_sf2. I don't see it handling (un)tagging or PVID
>> anywhere. It makes me believe such features are not implemented (and
>> not configurable) using bridges/dsa at all. Can you any API related to
>> untagging / PVID?
> 
> The (un)tagging code is in net/dsa/tag_brcm.c This is generic code, so
> you would not expect to find it in bcm_sf2. All you need to do is set
> 
>         .tag_protocol           = DSA_TAG_PROTO_BRCM,
> 
> in your dsa_switch_driver structure and the core DSA code will ensure
> the packets gets the header applied/removed.

This is untagging for the Broadcom tags, while Rafal is looking into
support the ndo_rx_vlan_{add,kill}_vid, which is something different here.
-- 
Florian
