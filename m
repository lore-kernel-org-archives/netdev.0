From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 03/10] Move two functions.
Date: Mon, 01 Oct 2007 15:27:08 +0200
Message-ID: <4700F5AC.9020609@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <1191019977559-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32831 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbXJAN1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:27:32 -0400
In-Reply-To: <1191019977559-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Move sfq_q_destroy() to above sfq_q_init() so that it can be used
> by an error case in a later patch.
> 
> Move sfq_destroy() as well, for clarity.


This patch looks pointless, just put them where you need them
in the patch introducing them.
