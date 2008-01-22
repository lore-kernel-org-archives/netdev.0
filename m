From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/12 net-2.6.25] [NETNS]: Re-export init_net via EXPORT_SYMBOL.
Date: Tue, 22 Jan 2008 18:04:40 +0100
Message-ID: <47962228.3000302@trash.net>
References: <479612BE.8030409@openvz.org> <1201017566-16985-5-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53955 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827AbYAVRFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 12:05:09 -0500
In-Reply-To: <1201017566-16985-5-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> init_net is used added as a parameter to a lot of old API calls, f.e.
> ip_dev_find. These calls were exported as EXPORT_SYMBOL. So, export init_net
> as EXPORT_SYMBOL to keep networking API consistent.


I think this should go in 2.6.24 if still possible so people
don't have to find workarounds that will be obsolete one
version later.
