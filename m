From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: fix jumbo packet support
Date: Wed, 24 May 2006 00:36:25 -0400
Message-ID: <4473E2C9.6080603@pobox.com>
References: <20060522120342.20f752e5@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43998 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932567AbWEXEg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 00:36:28 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060522120342.20f752e5@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The truncate threshold calculation to prevent receiver from getting stuck
> was incorrect, and it didn't take into account the upper limit on bits
> in the register so the jumbo packet support was broken.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

applied


