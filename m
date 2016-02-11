From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next RFC 1/6] Introduce devlink infrastructure
Date: Thu, 11 Feb 2016 15:31:36 +0100
Message-ID: <56BC9B48.5080708@redhat.com>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <1454496482-13961-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35132 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbcBKObt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 09:31:49 -0500
In-Reply-To: <1454496482-13961-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3.2.2016 11:47, Jiri Pirko wrote:
> +struct devlink_ops {
> +	size_t priv_size;
> +	int (*port_type_set)(struct devlink_port *devlink_port,
> +			     enum devlink_port_type port_type);
> +};
It does not make sense to have priv_size member here... If it is 
necessary it should be placed in struct devlink.

Ivan
