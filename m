From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] [PATCH] qeth: remove needless IPA-commands in
 offline
Date: Sat, 26 Feb 2011 22:41:44 -0800 (PST)
Message-ID: <20110226.224144.115932133.davem@davemloft.net>
References: <20110218142258.791988211@de.ibm.com>
	<20110218142343.763210392@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39020
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751235Ab1B0GlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 01:41:08 -0500
In-Reply-To: <20110218142343.763210392@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Fri, 18 Feb 2011 15:22:59 +0100

> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> If a qeth device is set offline, data and control subchannels are
> cleared, which means removal of all IP Assist Primitive settings
> implicitly. There is no need to delete those settings explicitly.
> This patch removes all IP Assist invocations from offline.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied.
