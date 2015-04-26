From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net 0/2] net/ethtool, mlx4_en: RSS hash function setting fixes
Date: Sun, 26 Apr 2015 20:18:28 +0300
Message-ID: <CAJ3xEMh2fbToSmRkx77VrppTfxFNKa17TpewbjZzyWrzU6fisA@mail.gmail.com>
References: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35473 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbbDZRS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 13:18:28 -0400
Received: by obcux3 with SMTP id ux3so68700869obc.2
        for <netdev@vger.kernel.org>; Sun, 26 Apr 2015 10:18:28 -0700 (PDT)
In-Reply-To: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 26, 2015 at 5:36 PM, Amir Vadai <amirv@mellanox.com> wrote:
> Hi Dave,
>
> This small patchset fixes a small issue in the ethtool User/kernel API.
>
> Hash function is represented as an eight bit field, every bit represents a
> function.  Currently possible values are: 1 for Toeplitz and 2 for XOR.
> This commit changes the representation from bit flags into a value. Because
> only one hash function will be used at a time, there is no sense using bit
> flags for it.
> Since today only 2 functions are supported, and there is no user space ethtool
> that supports this feature, we can switch into values without causing any
> backward compatibility issues.
>
> After this patchset is applied, I will send the user space patch.
>
> In this occasion I added a missing validation to the hash function value.
>
> This patchset was applied and tested over commit 2ea2f62 ("net: fix crash in build_skb()")
>
> Please push this patchset to stable 3.19.y in which those two issues were introduced.

and 4.0.y too I guess?
