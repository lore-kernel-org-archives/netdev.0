From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 v2] bonding: allow resetting slave failure
 counters
Date: Wed, 1 Jun 2011 22:08:55 +0200
Message-ID: <20110601200854.GD2784@psychotron.redhat.com>
References: <1306921249-3623-1-git-send-email-jpirko@redhat.com>
 <4DE63E85.7020508@redhat.com>
 <20110601135321.GA2909@psychotron.brq.redhat.com>
 <16056.1306944819@death>
 <20110601163153.GB2784@psychotron.redhat.com>
 <4DE6919F.3030304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, Flavio Leitner <fbl@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290Ab1FAUJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 16:09:00 -0400
Content-Disposition: inline
In-Reply-To: <4DE6919F.3030304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 01, 2011 at 09:23:11PM CEST, nicolas.2p.debian@gmail.com wrote=
:
>Le 01/06/2011 18:31, Jiri Pirko a =E9crit :
>>This patch allows to reset failure counters for all enslaved devices.
>
>Hi Jiri,
>
>Why do we need a way to reset those counters? What is the problem
>with having those counters monotonically increase until the system is
>rebooted? Do we have a way to reset other network statistics
>(/sys/class/net/eth0/statistics/* for example)?

Well, it's handy to be able to clear this counters when you resolve
a problem so future issues are crearly seen as non-zero.				  =20
				  =20
>
>Except from this "do we need this feature" question, the code sounds g=
ood to me.
>
>Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>
>	Nicolas.
