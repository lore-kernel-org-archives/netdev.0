From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks
	with	__maybe_unused
Date: Wed, 20 Feb 2008 07:56:32 -0800
Message-ID: <1203522992.7181.169.camel@localhost>
References: <47BC3303.2040101@openvz.org>
	 <1203521357.7181.163.camel@localhost>  <47BC4908.7010104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1093 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754452AbYBTP45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:56:57 -0500
In-Reply-To: <47BC4908.7010104@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sigh... Why is that better than a strait declaration with attribute?

If at some point there's a gcc'ism to remove a maybe_unused
variable from the stack declaration, you only have change
the macro.

cheers, Joe


