From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH] Netlink messages for multicast HW addr programming
Date: Thu, 4 Feb 2016 10:41:11 +1100
Message-ID: <20160204104111.0c21ab2f@samsung9>
References: <1453376874-17389-1-git-send-email-pruddy@brocade.com>
	<20160121200419.GB2251@nanopsycho.orion>
	<1453474315.20378.7.camel@brocade.com>
	<20160122150508.GD2211@nanopsycho.orion>
	<1453477775.20378.15.camel@brocade.com>
	<20160123075331.GA2193@nanopsycho.orion>
	<1454508881.3700.63.camel@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Stapleton <dstaplet@Brocade.com>,
	"Olufemi Komolafe" <okomolaf@Brocade.com>
To: Patrick Ruddy <pruddy@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:29728 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755497AbcBCXlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 18:41:19 -0500
In-Reply-To: <1454508881.3700.63.camel@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Feb 2016 06:14:41 -0800
Patrick Ruddy <pruddy@Brocade.com> wrote:

> One more Q on this. I can use IFA_ADDRESS for unicast addresses and
> IFA_MULTICAST for multicast addresses but are these distinctions
> actually required since the multicast nature of an address is clear from
> the address itself - at least it is for ethernet and ifininet?

The flags on L2 addresses should be analagous to what happens with L3 (IP) addresses.
