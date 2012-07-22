From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Sun, 22 Jul 2012 13:29:43 +0300
Message-ID: <500BD617.20800@mellanox.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	<cascardo@linux.vnet.ibm.com>, <brking@linux.vnet.ibm.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu2sys200bog102.obsmtp.com ([207.126.150.230]:55664 "HELO
	eu2sys200bog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750986Ab2GVK3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 06:29:52 -0400
In-Reply-To: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/20/2012 10:55 PM, Kleber Sacilotto de Souza wrote:
> Currently the mlx4 drivers don't have the necessary callbacks to
> implement EEH errors detection and recovery [...]

Hi,

Shlomo Pongratz  from Mellanox took a look on the patch, and we'd like 
to clarify with you something - OTOH you mention EEH (Extended Error 
Handling) error recovery which is a PPC related term mentioned in 
Documentation/powerpc/eeh-pci-error-recovery.txt, but OTHO you've 
implemented callbacks mentioned in the AER (Advanced Error Reporting) 
doc of Documentation/PCI/pcieaer-howto.txt, is there anything in the 
code you added which maybe implicitly assumes PPC arch?


Or.
