From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net 0/2] net/bonding: fixes related to neigh
Date: Tue, 3 Apr 2012 21:58:41 +0300
Message-ID: <CAJZOPZLttowLPfjd3Q6+v2XeYijzc-byu-+URWWoVf6Xaxq4xg@mail.gmail.com>
References: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:56300 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754516Ab2DCS6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 14:58:43 -0400
Received: by lahj13 with SMTP id j13so35577lah.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 11:58:42 -0700 (PDT)
In-Reply-To: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 2, 2012 at 7:17 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> This small patch set fixes some issues we stepped on when preparing
> for some IPoIB changes.
>
> With the 1st patch, the kernel networking code of arp_netdev_event calls
> neigh_changeaddr which further flashes the boding neighbours in some more
> cases which weren't covered by commit 7d26bb103 "bonding: emit event when
> bonding changes MAC"
>
> The 2nd patch fixes a bug where under bonding, the IPoIB neigh cleanup
> function wasn't called.

Hi Jay,

Could you have a look on these patches, its important for us to know
if we're on the right direction.

Or.
