From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/3] ethtool: dump_registers post mortem
Date: Sat, 21 Oct 2006 14:15:11 -0400
Message-ID: <453A63AF.1010505@pobox.com>
References: <20061018104632.27a37d75@freekitty> <20061018105022.57b57b6a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:13036 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1766641AbWJUSPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 14:15:14 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061018105022.57b57b6a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch allows:
> 	ethtool -d eth0 raw on >saved_regs
> and later
> 	ethtool -d eth0 file saved_regs
> 
> Selfish motive is to be able to take register dumps from users and
> and decode later, possibly adding more output as needed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Would you be kind enough to roll your ethtool patches into two patches: 
  this patch, and 'more sky2 decode' patch.  I now have three sky2 
decode patches, two from 10/18 and one from 10/19.

Also, please update the man page, and possibly the -h help info, to 
indicate this enhancement.

	Jeff



