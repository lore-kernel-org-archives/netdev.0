From: Pannirselvam Kanagaratnam <pannir@xsmail.com>
Subject: Re: Device Tree Binding for Marvell DSA on P1023RDB
Date: Tue, 17 Jun 2014 14:41:00 +0800
Message-ID: <539FE2FC.4020105@xsmail.com>
References: <539F1B3F.6060203@xsmail.com> <539F1B8E.30503@xsmail.com> <CAGVrzcbxBE0yk5J1Pvkz5Yx+ugHTBjRSTLsvN9NACt20vjmgjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60519 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752160AbaFQGlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 02:41:07 -0400
In-Reply-To: <CAGVrzcbxBE0yk5J1Pvkz5Yx+ugHTBjRSTLsvN9NACt20vjmgjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 17/06/2014 12:38 AM, Florian Fainelli wrote:
> 2014-06-16 9:30 GMT-07:00 Pannirselvam Kanagaratnam <pannir@xsmail.com>:
> Distributed Switch Architecture driver version 0.1
> dsa: probe of dsa.16 failed with error -22
> This error might not come from dsa_of_probe(), please instrument the
> code where -EINVAL is returned to see exactly which part of the
> probing code is failing.

The error is coming from:

dev = dev_to_net_device(pd->netdev);
if (dev == NULL) {
		ret = -EINVAL;
		goto out;
	}

Is my device tree ok?
