From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net] net: fix feature changes on devices without ndo_set_features
Date: Fri, 13 Nov 2015 09:34:28 -0500
Message-ID: <5645F4F4.1000307@redhat.com>
References: <5645C0A5.2080506@cumulusnetworks.com> <1447422841-2333-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799AbbKMOec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 09:34:32 -0500
In-Reply-To: <1447422841-2333-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov<nikolay@cumulusnetworks.com>
>
> When __netdev_update_features() was updated to ensure some features are
> disabled on new lower devices, an error was introduced for devices which
> don't have the ndo_set_features() method set. Before we'll just set the
> new features, but now we return an error and don't set them. Fix this by
> returning the old behaviour and setting err to 0 when ndo_set_features
> is not present.
>
> Fixes: e7868a85e1b2 ("net/core: ensure features get disabled on new lower devs")
> CC: Jarod Wilson<jarod@redhat.com>
> CC: Jiri Pirko<jiri@resnulli.us>
> CC: Ido Schimmel<idosch@mellanox.com>
> CC: Sander Eikelenboom<linux@eikelenboom.it>
> CC: Andy Gospodarek<gospo@cumulusnetworks.com>
> CC: Florian Fainelli<f.fainelli@gmail.com>
> Signed-off-by: Nikolay Aleksandrov<nikolay@cumulusnetworks.com>
> ---
> Sander please feel free to give your Tested-by.

Ah, good catch, thank you for cleaning up my mess.

Reviewed-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
