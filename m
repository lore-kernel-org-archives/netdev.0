From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Thu, 6 Mar 2014 19:28:22 +0100
Message-ID: <19514b391e2cebb00f895de862f2a598.squirrel@webmail.itwm.fhg.de>
References: <7c9810ea21990e7e239b101f548818f7.squirrel@webmail.itwm.fhg.de>
    <20140305.193913.470467212827707623.davem@redhat.com>
    <20140306111139.2b7b6b8b@zoidberg>
    <20140306.130746.1333492573211031660.davem@davemloft.net>
Reply-To: phoebe.buckheister@itwm.fraunhofer.de
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: phoebe.buckheister@itwm.fraunhofer.de, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:43157 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbaCFS20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 13:28:26 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s26ISNws012859
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 6 Mar 2014 19:28:24 +0100
In-Reply-To: <20140306.130746.1333492573211031660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Why is that surprising?  It's the network header.

I have a rather language-lawyerly background and tend to err on the side
of caution by assuming that all implementation-defined behaviour, such as
allocation and order of bitfield members, *will* break in the wild once
enough architectures are involved. Thus my surprise and question.

> memcpy() "just works"

Perfect. Thank you for your patience :)
