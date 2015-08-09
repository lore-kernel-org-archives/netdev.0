From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v4 3/4] openvswitch: Use regular GRE net_device
 instead of vport
Date: Sun, 9 Aug 2015 18:19:24 +0200
Message-ID: <20150809161924.GF3113@pox.localdomain>
References: <1438830760-6572-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33639 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933047AbbHIQT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 12:19:26 -0400
Received: by wijp15 with SMTP id p15so109351064wij.0
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 09:19:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438830760-6572-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/15 at 08:12pm, Pravin B Shelar wrote:
> Using flow based tunneling, we can implement
> OVS GRE vport. This patch removes all of the OVS
> specific GRE code and make OVS use a ip_gre net_device.
> Minimal GRE vport is kept to handle compatibility with
> current userspace application.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

After the dependency fix:
Acked-by: Thomas Graf <tgraf@suug.ch>
