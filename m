From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 04/11] openvswitch: Restructure datapath.c and
 flow.c
Date: Tue, 29 Oct 2013 18:25:13 -0700
Message-ID: <1383096313.12439.44.camel@joe-AO722>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
	 <1383092544-50599-5-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org, Pravin B Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0059.hostedemail.com ([216.40.44.59]:41076 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751995Ab3J3BZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 21:25:18 -0400
In-Reply-To: <1383092544-50599-5-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 17:22 -0700, Jesse Gross wrote:
> Over the time datapath.c and flow.c has became pretty large files.
> Following patch restructures functionality of component into three
> different components:
[]
>  net/openvswitch/Makefile       |    2 +
>  net/openvswitch/datapath.c     |  528 +------------
>  net/openvswitch/datapath.h     |    1 +
>  net/openvswitch/flow.c         | 1605 +---------------------------------------
>  net/openvswitch/flow.h         |  128 +---
>  net/openvswitch/flow_netlink.c | 1603 +++++++++++++++++++++++++++++++++++++++

Is this largish patch any different or easier to
read/verify when generated with git format-patch -M ?
