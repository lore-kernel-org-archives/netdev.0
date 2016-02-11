From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/6] Introduce devlink infrastructure
Date: Thu, 11 Feb 2016 17:54:37 +0100
Message-ID: <20160211165437.GA2487@nanopsycho.us.es>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <1454496482-13961-2-git-send-email-jiri@resnulli.us>
 <56BC9B48.5080708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36765 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbcBKQyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 11:54:40 -0500
Received: by mail-wm0-f44.google.com with SMTP id p63so82315385wmp.1
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 08:54:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56BC9B48.5080708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 11, 2016 at 03:31:36PM CET, ivecera@redhat.com wrote:
>On 3.2.2016 11:47, Jiri Pirko wrote:
>>+struct devlink_ops {
>>+	size_t priv_size;
>>+	int (*port_type_set)(struct devlink_port *devlink_port,
>>+			     enum devlink_port_type port_type);
>>+};
>It does not make sense to have priv_size member here... If it is necessary it
>should be placed in struct devlink.

I forgot to remove this. Will do that. Thanks!
