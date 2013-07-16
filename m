From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [patch net-next v2] nlmon: use standard rtnetlink link api for add/del devices
Date: Tue, 16 Jul 2013 14:08:51 +0000 (UTC)
Message-ID: <loom.20130716T160603-964@post.gmane.org>
References: <1372755331-1267-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45883 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932183Ab3GPOPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 10:15:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Uz61v-0003QL-Mo
	for netdev@vger.kernel.org; Tue, 16 Jul 2013 16:15:03 +0200
Received: from 185.23.60.4 ([185.23.60.4])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 16:15:03 +0200
Received: from qca_vkondrat by 185.23.60.4 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 16:15:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri <at> resnulli.us> writes:

> 
> It is not nice when netdev is created right after module load and with
> some implicit name. So rather change nlmon to use standard rtnl link API.
> 

Could you please elaborate a bit - how to capture netlink skb's after your
patch? Before, it was netdev that may be used with tcpdump. Now, there is
no such netdev. How to create it?
