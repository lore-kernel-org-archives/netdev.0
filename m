From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bonding Overriding Configuration logic restored.
Date: Tue, 31 Mar 2015 13:50:05 -0400 (EDT)
Message-ID: <20150331.135005.914314420842054696.davem@davemloft.net>
References: <1427628025-9752-1-git-send-email-anton@swortex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexey@swortex.com
To: anton@swortex.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427628025-9752-1-git-send-email-anton@swortex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Nayshtut <anton@swortex.com>
Date: Sun, 29 Mar 2015 14:20:25 +0300

> Before commit 3900f29021f0bc7fe9815aa32f1a993b7dfdd402 ("bonding: slight
> optimizztion for bond_slave_override()") the override logic was to send packets
> with non-zero queue_id through the slave with corresponding queue_id, under two
> conditions only - if the slave can transmit and it's up.
> 
> The above mentioned commit changed this logic by introducing an additional
> condition - whether the bond is active (indirectly, using the slave_can_tx and
> later - bond_is_active_slave), that prevents the user from implementing more
> complex policies according to the Documentation/networking/bonding.txt.
> 
> Signed-off-by: Anton Nayshtut <anton@swortex.com>
> Signed-off-by: Alexey Bogoslavsky <alexey@swortex.com>

Applied and queued up for -stable, thanks.
