From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 8/10][NETNS][FRAGS]: Isolate the secret
 interval from namespaces.
Date: Tue, 22 Jan 2008 06:11:16 -0800 (PST)
Message-ID: <20080122.061116.249192651.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F88E.9090202@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49802
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755841AbYAVOLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:11:09 -0500
In-Reply-To: <4795F88E.9090202@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 17:07:10 +0300

> Since we have one hashtable to lookup the fragment, having
> different secret_interval-s for hash rebuild doesn't make 
> sense, so move this one to inet_frags.
> 
> The inet_frags_ctl becomes empty after this, so remove it.
> The appropriate ctl table is kept read-only in namespaces.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
