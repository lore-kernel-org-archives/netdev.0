From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool: add sky2 register dump
Date: Wed, 27 Sep 2006 18:01:21 -0400
Message-ID: <451AF4B1.2000208@pobox.com>
References: <20060926115437.11ed1f85@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:61127 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1031036AbWI0WBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 18:01:23 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060926115437.11ed1f85@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Add support for sky2 register dump, put it in a common file
> for both skge and sky2.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

You should know this by now:  separate out logical changes into multiple 
patches.

When renaming a file AND making changes to it, your changes are 
completely obscured by the rename.

First patch should do the rename, but not change existing code.  Second 
patch should include any code updates you wish to make.

ACK changes, NAK in present form.


