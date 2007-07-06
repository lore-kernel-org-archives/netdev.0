From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net : make netlink_seq_ops const
Date: Fri, 06 Jul 2007 14:52:11 +0200
Message-ID: <468E3AFB.7060403@trash.net>
References: <20070706124829.GA12930@muff.macqel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57080 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761989AbXGFMwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 08:52:34 -0400
In-Reply-To: <20070706124829.GA12930@muff.macqel.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[please send networking patches to netdev]

Philippe De Muyter wrote:
> Hi all,
> 
> Make netlink_seq_ops const


Might make more sense to do a big patch for all occurences of this
in net/:

# grep "^static struct seq_operations" -r net/ | wc -l
76
