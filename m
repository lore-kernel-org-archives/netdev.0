From: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Subject: Re: PATCH: uninitialized memory access in tcp_parse_options
Date: Mon, 21 Jun 2010 21:10:46 +0200
Message-ID: <1277147446.9469.67.camel@localhost.localdomain>
References: <1277127249.9469.53.camel@localhost.localdomain>
	 <3E37AD8C-208F-42B8-AA04-E0B294D909A8@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:5472 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758193Ab0FUTKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 15:10:50 -0400
In-Reply-To: <3E37AD8C-208F-42B8-AA04-E0B294D909A8@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-21 at 11:02 -0700, Mitchell Erblich wrote:

> 		The standard default for TCP with IPv4 is 536, which
> 		translates to 576 MTU.
> 
> 		Thus, why don't you init mss to 536?

I don't know: I am not a tcp expert and I am not sure I really
understand the way this function is expected to be used by callers but I
sent a patch to make sure that someone would feel compelled to find the
right fix. It looks like callers of this function are expected to
initialize the fields themselves so, the idea of doing the
initialization in tcp_parse_options is probably bad.

Mathieu
-- 
Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Tel: +33 4 9238 5056

