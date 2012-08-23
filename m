From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] team: add support for non-ethernet devices
Date: Thu, 23 Aug 2012 10:32:06 +0200
Message-ID: <20120823083206.GC1592@minipsycho.orion>
References: <1345212048-1378-1-git-send-email-jiri@resnulli.us>
 <CAJZOPZLzL5KMF=HjJ=HZYNUerBXV2Es0cDq9rdP=ZYvsEJv7gA@mail.gmail.com>
 <20120823080412.GB1592@minipsycho.orion>
 <5035E6FF.1040609@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:50088 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933700Ab2HWIcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 04:32:11 -0400
Received: by wibhq12 with SMTP id hq12so698001wib.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 01:32:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5035E6FF.1040609@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 23, 2012 at 10:17:03AM CEST, ogerlitz@mellanox.com wrote:
>On 23/08/2012 11:04, Jiri Pirko wrote:
>>You are right. NETIF_F_VLAN_CHALLENGED feature needs to be considered in
>>team code.
>isn't that the team device has to follow on all the features/offloads
>of the active port?

active port (in ab mode) has no privileges over others.
features of team after port add/del/NETDEV_FEAT_CHANGE are adjusted in
__team_compute_features()

>
>Or.
