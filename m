From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] drivers/net/defxx.c: use %pM to show MAC address
Date: Mon, 4 Jan 2010 18:49:48 +0000 (GMT)
Message-ID: <alpine.LFD.2.00.1001041833560.13474@eddie.linux-mips.org>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F63E@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753787Ab0ADStz@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:36492 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1493258Ab0ADSts (ORCPT
        <rfc822;netdev@vger.kernel.org> + 1 other);
        Mon, 4 Jan 2010 19:49:48 +0100
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090200F63E@mi8nycmail19.Mi8.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Dec 2009, H Hartley Sweeten wrote:

> Use the %pM kernel extension to display the MAC address.
> 
> The only difference in the output is that the MAC address is
> shown in the usual colon-separated hex notation.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: David S. Miller <davem@davemloft.net>

 Nack.  While I appreciate your effort, the FDDI standard defines opposite 
bit-ordering for MAC addresses written in the dash-separated and the 
colon-separated hexadecimal notation, which makes your change invalid, 
sorry (you'd have to bit-swap them too and that would make addresses 
counter-intuitive).  Please note that `ifconfig' consistently uses the 
dash-separated notation for FDDI interfaces too (I haven't checked other 
tools like those in the "iproute" package; they may be buggy).

 [I'd appreciate to be CCed on patch submissions to code I claim 
maintenance of too.]

  Maciej
