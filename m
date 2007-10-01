From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Removing DAD in IPv6
Date: Mon, 01 Oct 2007 20:44:48 +0900 (JST)
Message-ID: <20071001.204448.130861285.yoshfuji@linux-ipv6.org>
References: <1191210807.25398.18.camel@orbit6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: xiayang@ntu.edu.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:51231 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbXJALnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 07:43:03 -0400
In-Reply-To: <1191210807.25398.18.camel@orbit6>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1191210807.25398.18.camel@orbit6> (at Mon, 01 Oct 2007 11:53:27 +0800), Xia Yang <xiayang@ntu.edu.sg> says:

> I would like to ask for help on how to remove or disable the DAD process
> properly, as long as the node can send, receive and forward packets
> immediately after a new IPv6 address is generated. Any pointer is
> appreciated. Thanks a lot in advance!

IFA_F_NODAD address flag might help this.

--yoshfuji
