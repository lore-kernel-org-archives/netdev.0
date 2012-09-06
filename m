From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 4/6] igb: Store the MAC address in the name in the
 PTP struct.
Date: Thu, 6 Sep 2012 10:06:28 +0200
Message-ID: <20120906080628.GD2550@netboy.at.omicron.at>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1346888106-25638-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:49071 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab2IFIGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:06:38 -0400
Received: by wibhi8 with SMTP id hi8so42735wib.1
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 01:06:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1346888106-25638-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 05, 2012 at 04:35:04PM -0700, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> Change the name of the adapter in the PTP struct to enable easier
> correlation between interface and PTP device.

Still think it is better to have the driver name, not the MAC address.
The correlation is clear by using the ethtool method.

Thanks,
Richard
