From: Jonas Bonn <jonas@southpole.se>
Subject: Re: [PATCH] [SIS190] Constify data marked as __devinitdata
Date: Wed, 30 Jan 2008 12:41:59 +0100
Message-ID: <47A06287.9080607@southpole.se>
References: <1201690388-9052-1-git-send-email-jonas@southpole.se> <Pine.LNX.4.64.0801301220570.15249@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:53935 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbYA3LmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 06:42:04 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id E01EEA0162
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 12:42:01 +0100 (CET)
In-Reply-To: <Pine.LNX.4.64.0801301220570.15249@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> instead? Because AFAIK, const *and* __sectionmarker does not mix.
 >

You're right... it's documented in linux/init.h that const and 
__sectionmarker do not mix.  The compile error is due to the use of 
const and __section marker in the function sis190_get_mac_addr_from_apc().

