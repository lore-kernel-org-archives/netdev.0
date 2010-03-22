From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netdev: don't always reset iflink when registering
Date: Mon, 22 Mar 2010 18:42:43 +0100
Message-ID: <4BA7AC13.3080408@trash.net>
References: <20100320013917.GB13239@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Goff <thomas.goff@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39967 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754984Ab0CVRmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 13:42:45 -0400
In-Reply-To: <20100320013917.GB13239@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Goff wrote:
> Bound tunnel devices set their iflink to the ifindex of the underlying
> network interface when created.  It shouldn't be reset by the
> registration process.
>   

Which ones exactly? Usually they do this in ->setup() or later on.
