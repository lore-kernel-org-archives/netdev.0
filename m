From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [net-next v2 13/15] i40e: limit WoL and link settings to
 partition 1
Date: Sun, 18 Jan 2015 06:10:19 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63BC8933@avmb3.qlogic.org>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>,<1421179093-10932-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Shannon Nelson <shannon.nelson@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:15601 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874AbbARGK2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2015 01:10:28 -0500
In-Reply-To: <1421179093-10932-14-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Shannon Nelson <shannon.nelson@intel.com>

>When in multi-function mode, e.g. Dell's NPAR, only partition 1
>of each MAC is allowed to set WoL, speed, and flow control.

Isn't it problematic? I mean, in bnx2x we address ~same issue -
but due to symmetry we prevent ALL interfaces from changing
the link configuration.

How can user be aware of this 'private' behavior? via system logs?
documentation?

How does it interact with Physical Device Assignment of the first
partition?

Cheers,
Yuval