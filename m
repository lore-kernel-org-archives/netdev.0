From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: more findings/questions on vlans/bonds
Date: Sun, 26 Apr 2009 11:21:22 +0300
Message-ID: <49F41982.4050608@Voltaire.com>
References: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com> <13724.1240520690@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:29763 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753618AbZDZIVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2009 04:21:36 -0400
In-Reply-To: <13724.1240520690@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
>> $ cat /sys/class/net/eth0.4001/carrier
>> cat: /sys/class/net/eth0.4001/carrier: Invalid argument

>         I suspect the "carrier: Invalid argument" response you describe
> above is a result of the show_carrier function in net-sysfs.c, which
> returns EINVAL if the device is not netif_running.  If the device (vlan
> or not) is running, the carrier is returned.

Yes, I see now that this is indeed the case with the sysfs code.

> So, here's a patch with a description.  This resolves the
> bonding problem for me

many thanks for doing this patch

Or.
