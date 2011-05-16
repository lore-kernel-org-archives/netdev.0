From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: [PATCH] output ipconfig info message as one printk
Date: Mon, 16 May 2011 20:12:34 +0200
Message-ID: <4DD16912.7030709@neli.hopto.org>
References: <1305409519-25404-1-git-send-email-micha@neli.hopto.org> <20110516.140035.72516501072074389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-02.edutel.nl ([88.159.1.172]:38569 "EHLO
	edu-smtp-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab1EPSNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 14:13:02 -0400
In-Reply-To: <20110516.140035.72516501072074389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Second, you should not do this because now the lines after the
> first won't have the default loglevel prepended.
> 
> I think this should just be left alone, and you should properly
> mark your netconsole logs so that you can discern which machine
> the individual messages come from so you can piece them together
> properly if you need to.

Hmm, perhaps the printks can at least be grouped per line?

Micha
