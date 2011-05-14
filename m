From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Fri, 13 May 2011 17:28:25 -0700
Message-ID: <1305332905.8149.705.camel@tardy>
References: <20110513171729.247b126e@nehalam>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:4826 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758522Ab1ENA21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 20:28:27 -0400
In-Reply-To: <20110513171729.247b126e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-13 at 17:17 -0700, Stephen Hemminger wrote:
> There are some addresses in the assigned vendor block that don't obey
> the locally assigned convention. These should be avoided by random_ether_addr
> assignment.

How "recent" are these violations?  Is there really a non-trivial chance
of colliding?  Much more than two or more stations in the same broadcast
domain randomly picking the same random MAC anyway?

At one level, avoiding using those OUIs seems to be a tacit approval of
the violations.

rick jones

