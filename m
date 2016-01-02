From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] stmmac: Don't exit mdio registration when mdio subnode is
 not found in the DTS
Date: Sat, 2 Jan 2016 09:52:06 -0800
Message-ID: <56880E46.4050206@gmail.com>
References: <1451397935-23643-1-git-send-email-romain.perier@gmail.com>
 <0E6F98A1-B9F1-48B0-B5CA-A215803E827F@gmail.com>
 <CABgxDoLNWEtYtRTrYhp7T=tk3n-aPMCgOP2SL7+DoxFqTk7GuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: peppe.cavallaro@st.com, netdev <netdev@vger.kernel.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34924 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbcABRwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 12:52:09 -0500
Received: by mail-oi0-f43.google.com with SMTP id l9so208543349oia.2
        for <netdev@vger.kernel.org>; Sat, 02 Jan 2016 09:52:08 -0800 (PST)
In-Reply-To: <CABgxDoLNWEtYtRTrYhp7T=tk3n-aPMCgOP2SL7+DoxFqTk7GuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/01/2016 07:11, Romain Perier a =C3=A9crit :
>>> Signed-off-by: Romain Perier <romain.perier@gmail.com>
>>
>> Please include a Fixes tag to help keep track of changes.
>=20
> Sure, sorry for my ignorance, but I did not know that we're supposed
> to add a Fixes tag in this situation.

It is a good practice and definitively helps making sure that if
regression entered a merge window, and a fix came in another merge
window, people can easily backport the fix, moving on..

[snip]

>> This looks reasonable, does it work if we just assign mdio_node to t=
he pdev->dev.of_node to be backwards compatible with DTSes which have n=
ot yet been updated?
>>
>=20
> I don't understand what you mean. Instead of defining mdio_node with
> NULL, you propose to assign it to pdev->dev.of_node as its default
> value... then it would be reassigned with "child_nod" if a subnode
> with the compatible string "snps,dwmac-mdio" is found, or kept with
> its default value otherwise... and in this case we could call
> of_mdiobus_register(new_bus, mdio_node) all the time ? (it removes th=
e
> conditonnal branch)

Your understanding is correct, this is what I was suggesting, thanks
--=20
=46lorian
