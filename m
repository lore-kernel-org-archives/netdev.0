From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [PATCH] skge: don't clear MC state on link down
Date: Fri, 1 Dec 2006 16:03:53 -0500
Message-ID: <bdfc5d6e0612011303n73db0f39p62cef91d1e6703f1@mail.gmail.com>
References: <20061130163531.GB8772@gospo.rdu.redhat.com>
	 <20061201114108.6166cb47@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:1631 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161383AbWLAVDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 16:03:55 -0500
Received: by ug-out-1314.google.com with SMTP id 44so2533476uga
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 13:03:54 -0800 (PST)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20061201114108.6166cb47@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/1/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> I would rather fix Andy's problem by not clearing
> multicast information on link down.
>
> Also, add code to restore multicast state after ethtool phy reset.
>

Stephen,

I'll ACK that change instead as long as we can be sure that this isn't
needed for hardware reasons.

-andy
