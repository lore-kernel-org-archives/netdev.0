From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: Re: [PATCH linux v3 net-next 4/4] bonding: add netlink support for
 sys prio, actor sys mac, and port key
Date: Sun, 10 May 2015 09:54:15 +0200
Message-ID: <554F0EA7.4060000@blackwall.org>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com> <c26a9459226784190a8503418c1375bfe1f90cae.1431150701.git.jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	shm@cumulusnetworks.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33071 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbbEJHyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 03:54:33 -0400
Received: by wief7 with SMTP id f7so63987156wie.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 00:54:32 -0700 (PDT)
In-Reply-To: <c26a9459226784190a8503418c1375bfe1f90cae.1431150701.git.jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/15 09:01, Jonathan Toppins wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
>
> Adds netlink support for the following bonding options:
> * BOND_OPT_AD_ACTOR_SYS_PRIO
> * BOND_OPT_AD_ACTOR_SYSTEM
> * BOND_OPT_AD_USER_PORT_KEY
>
> When setting the actor system mac address we assume the netlink message
> contains a binary mac and not a string representation of a mac.
>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> [jt: completed the setting side of the netlink attributes]
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
>  v2:
>     * rebased
>  v3:
>     * removed parenthesis from around values in the netdev_info calls in
>       bond_option_ad_actor_sys_prio_set() and
>       bond_option_ad_user_port_key_set()
>     * fixed up bond_option_ad_actor_system_set() to support handling both
>       string and value setting as Nik suggested
>
>  drivers/net/bonding/bond_netlink.c |   50 ++++++++++++++++++++++++++++++++++++
>  drivers/net/bonding/bond_options.c |   30 +++++++++++++++-------
>  include/uapi/linux/if_link.h       |    3 +++
>  3 files changed, 74 insertions(+), 9 deletions(-)
>
>

Thank you for re-working this, it actually looks better than I thought it
would. I'm traveling right now and can't test it, but I went over the patch
and it looks good to me.

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
