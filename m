From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Mon, 6 Aug 2007 11:00:45 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABA1D@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070805.232423.21363072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: shemminger@linux-foundation.org, jgarzik@pobox.com,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3668 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761539AbXHFSBo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 14:01:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070805.232423.21363072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> 4) NETPOLL put hopefully into a working state.

It's no longer necessary to change the tx locking scheme
in bnx2.c and tg3.c, right?  May be you forgot to revert
the tx locking changes you did in V4?

