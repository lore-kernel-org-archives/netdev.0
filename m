From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 2/3] sky2: fix VLAN receive processing
Date: Fri, 28 Sep 2007 20:40:59 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709282039400.24092@bizon.gios.gov.pl>
References: <20070928164811.387831540@linux-foundation.org>
 <20070928164858.539587428@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Greg KH <greg@kroah.com>, stable@kernel.org,
	netdev@vger.kernel.org, Pierre-Yves Ritschard <pyr@spootnik.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:56197 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756222AbXI1SlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 14:41:25 -0400
In-Reply-To: <20070928164858.539587428@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 28 Sep 2007, Stephen Hemminger wrote:

> The length check for truncated frames was not correctly handling
> the case where VLAN acceleration had already read the tag.
> Also, the Yukon EX has some features that use high bit of status
> as security tag.
>

Thank you.



Best regards

 					Krzysztof Oledzki
