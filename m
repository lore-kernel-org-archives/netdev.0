From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 5/9] net: dsa: mv88e6352: disable mirroring
Date: Tue, 02 Jun 2015 07:16:10 -0700
Message-ID: <556DBAAA.4010408@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-6-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:45557 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755649AbbFBOQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 10:16:15 -0400
In-Reply-To: <1433208470-25338-6-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2015 06:27 PM, Vivien Didelot wrote:
> Disable the mirroring policy in the monitor control register, since this
> feature is not needed.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Should this be a separate patch, unrelated to the patch set ?

If I understand correctly, this effectively disables IGMP/MLD snooping.
I think this warrants an explanation why that it not needed, not just
a statement that it is not needed.

Thanks,
Guenter
