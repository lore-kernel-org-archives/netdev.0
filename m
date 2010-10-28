From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: Fix unused variable warning.
Date: Wed, 27 Oct 2010 19:13:23 -0700
Message-ID: <AANLkTi=iDMYjMsvbeR9-ZhCE5zMHacO-vM5wTXvx4S9K@mail.gmail.com>
References: <1288140963-20537-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48870 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757632Ab0J1CNY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 22:13:24 -0400
Received: by iwn10 with SMTP id 10so1761562iwn.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 19:13:23 -0700 (PDT)
In-Reply-To: <1288140963-20537-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 17:56, Jesse Gross <jesse@nicira.com> wrote:
> Commit eab6d18d "vlan: Don't check for vlan group before
> vlan_tx_tag_present" removed the need for the adapter variable
> in igb_xmit_frame_ring_adv(). =C2=A0This removes the variable as well
> to avoid the compiler warning.
>
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
> =C2=A0drivers/net/igb/igb_main.c | =C2=A0 =C2=A01 -
> =C2=A01 files changed, 0 insertions(+), 1 deletions(-)
>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
