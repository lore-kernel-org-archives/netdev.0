From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2] bonding: add option to specify the number
 of queues per bond device
Date: Tue, 05 Nov 2013 17:50:35 +0100
Message-ID: <527921DB.2090803@redhat.com>
References: <1383670049-15235-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, fubar@us.ibm.com, vfalico@redhat.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab3KEQx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 11:53:58 -0500
In-Reply-To: <1383670049-15235-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2013 05:47 PM, Nikolay Aleksandrov wrote:
> Before this patch the only way to specify the number of queues of a bond
> device was to use the tx_queues module parameter on module load. Since
> we can have different setups with different requirements, it's
> beneficial to be able to specify the number of queues per bond device
> creation. This patch adds this ability and uses tx_queues as a default
> and as a fallback in case of an invalid "queues" value.
> The queues are specified when creating a new bond device through sysfs
> by using " " as a delimiter between the name and the value, e.g.:
> echo "+bond1 8" > bonding_masters
> will create bond1 device with 8 queues.
> Add an example in the documentation, and also trim a few extra spaces
> and tabs while at it.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---

Aaaaargh, I'm not posting anymore patches today.
Self-nack again, I forgot about the queues initialization in the store_bonds and
that ends up in a warning when no value is specified, I'm so mad at myself.

Apologies again, this patch can be reviewed as I intend to post a v3 with the
proper initialization of queues to tx_queues in store_bonds as the only change.

Nik
