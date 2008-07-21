From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Traffic control cgroups subsystem
Date: Mon, 21 Jul 2008 16:05:30 +0200
Message-ID: <488497AA.7000407@trash.net>
References: <Pine.LNX.4.64.0807181428180.18212@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	menage@google.com
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38366 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbYGUOFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 10:05:31 -0400
In-Reply-To: <Pine.LNX.4.64.0807181428180.18212@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ranjit Manomohan wrote:
> This patch implements a filter that classifies packets based upon
> the cgroup_classid of the packet.

I'd suggest to add this to the flow classifier (cls_flow.c),
adding a full classifier is overkill just for this one field.
