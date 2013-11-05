From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: add option to specify the number of
 queues per bond device
Date: Tue, 05 Nov 2013 16:45:11 +0100
Message-ID: <52791287.1070101@redhat.com>
References: <1383666093-4115-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, fubar@us.ibm.com, vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab3KEPsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 10:48:35 -0500
In-Reply-To: <1383666093-4115-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2013 04:41 PM, Nikolay Aleksandrov wrote:
> Before this patch the only way to specify the number of queues of a bond
> device was to use the tx_queues module parameter on module load. Since
> we can have different setups with different requirements, it's
> beneficial to be able to specify the number of queues per bond device
> creation. This patch adds this ability and uses tx_queues as a default
> and as a fallback in case of an invalid "queues" value.
> The queues are specified when creating a new bond device through sysfs
> by using the ":" as a delimiter between the name and the value, e.g.:
> echo +bond1:8 > bonding_masters
> will create bond1 device with 8 queues. The value 0 is reserved for
> using the default number of queues (global tx_queues set on module
> loading).
> Add an example in the documentation, and also trim a few extra spaces
> and tabs while at it.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
ugh, self-nack I chose the wrong delimiter, it's allowed to be in an interface
name :-)

Will re-post by using "." as a delimiter.
Sorry for the noise.

Nik
