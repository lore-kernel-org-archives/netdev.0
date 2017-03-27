From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 3/3] net: phy: allow EEE with SGMII interface modes
Date: Mon, 27 Mar 2017 11:03:12 -0700
Message-ID: <9f523664-9479-26ca-e3f7-95453ed03560@gmail.com>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
 <E1csRQT-0004rM-Tq@rmk-PC.armlinux.org.uk>
 <5d3c3ce0-fabc-6b96-c7e9-c2e46ffe4d23@gmail.com>
 <20170327170019.GR7909@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36774 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdC0SD4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:03:56 -0400
Received: by mail-wr0-f196.google.com with SMTP id u1so15588416wra.3
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:03:41 -0700 (PDT)
In-Reply-To: <20170327170019.GR7909@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2017 10:00 AM, Russell King - ARM Linux wrote:
> On Mon, Mar 27, 2017 at 09:47:31AM -0700, Florian Fainelli wrote:
>> On 03/27/2017 02:59 AM, Russell King wrote:
>>> As EEE is able to work in SGMII mode as well, add it to the list of
>>> permissable EEE modes that phy_init_eee() will accept.  This is
>>> necessary so that EEE can work with an 88E1512 connected in SGMII mode.
>>
>> As you mention in your cover letter, we should probably reverse this
>> test and make it reject modes where EEE has no chance of being supported
>> at all.
> 
> Want me to re-spin?  Any thought on which interface modes we should
> explicitly exclude?

It actually sounds like we should just kill the check entirely, it does
not appear that any of the interface mode would not fundamentally be
able to support EEE, because the "lowest" mode we support is MII, and
even there it's quite possible to support EEE.
-- 
Florian
