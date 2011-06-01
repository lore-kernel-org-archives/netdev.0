From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 v2] bonding: allow resetting slave failure
 counters
Date: Wed, 01 Jun 2011 21:23:11 +0200
Message-ID: <4DE6919F.3030304@gmail.com>
References: <1306921249-3623-1-git-send-email-jpirko@redhat.com> <4DE63E85.7020508@redhat.com> <20110601135321.GA2909@psychotron.brq.redhat.com> <16056.1306944819@death> <20110601163153.GB2784@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, Flavio Leitner <fbl@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45990 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756080Ab1FATXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 15:23:14 -0400
Received: by wya21 with SMTP id 21so95046wya.19
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 12:23:13 -0700 (PDT)
In-Reply-To: <20110601163153.GB2784@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/06/2011 18:31, Jiri Pirko a =E9crit :
> This patch allows to reset failure counters for all enslaved devices.

Hi Jiri,

Why do we need a way to reset those counters? What is the problem with =
having those counters=20
monotonically increase until the system is rebooted? Do we have a way t=
o reset other network=20
statistics (/sys/class/net/eth0/statistics/* for example)?

Except from this "do we need this feature" question, the code sounds go=
od to me.

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

	Nicolas.
