From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Thu, 10 Jan 2008 01:38:57 +0900 (JST)
Message-ID: <20080110.013857.37616214.yoshfuji@linux-ipv6.org>
References: <20080109153656.GA16962@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34731 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbYAIQi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 11:38:56 -0500
In-Reply-To: <20080109153656.GA16962@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080109153656.GA16962@pingi.kke.suse.de> (at Wed, 9 Jan 2008 16:36:56 +0100), Karsten Keil <kkeil@suse.de> says:

> So I think we should disable the interface now, if DAD fails on a
> hardware based LLA.

I don't want to do this, at least, unconditionally.

Options (not exclusive):

- we could have "enable_ipv6" interface flag and check it in
  input/output paths
- we could have "dad_reaction" interface variable and
 > 1: disable interface
 = 1: disable IPv6
 < 0: ignore (as we do now)

--yoshfuji
