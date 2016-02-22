From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] lwtunnel: autoload of lwt modules
Date: Sun, 21 Feb 2016 22:00:47 -0500 (EST)
Message-ID: <20160221.220047.582354891121433128.davem@davemloft.net>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
	<1455874998-26795-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	tom@herbertland.com, tgraf@suug.ch, ebiederm@xmission.com,
	jbenc@redhat.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbcBVDAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 22:00:49 -0500
In-Reply-To: <1455874998-26795-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Fri, 19 Feb 2016 09:43:15 +0000

> Changes since v1:
>  - remove "LWTUNNEL_ENCAP_" prefix for the string form of the encaps
>    used when requesting the module to reduce duplication, and don't
>    bother returning strings for lwt modules using netdevices, both
>    suggested by Jiri.
>  - update commit message of first patch to clarify security
>    implications, in response to Eric's comments.
> 
> The lwt implementations using net devices can autoload using the
> existing mechanism using IFLA_INFO_KIND. However, there's no mechanism
> that lwt modules not using net devices can use.
> 
> Therefore, these patches add the ability to autoload modules
> registering lwt operations for lwt implementations not using a net
> device so that users don't have to manually load the modules.

Series applied, thanks.
