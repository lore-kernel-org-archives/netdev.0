From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV probes
Date: Thu, 18 Apr 2013 12:40:09 +0300
Message-ID: <201304181240.10239.jackm@dev.mellanox.co.il>
References: <20130411153030.GA22743@redhat.com> <20130414134339.GA3050@htj.dyndns.org> <20130418083347.GA16526@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:47987 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967611Ab3DRJjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 05:39:42 -0400
Received: by mail-we0-f176.google.com with SMTP id s43so1974259wey.7
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 02:39:41 -0700 (PDT)
In-Reply-To: <20130418083347.GA16526@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 18 April 2013 11:33, Michael S. Tsirkin wrote:
> But for pci_sriov_enable, the situation is actually very simple:
> VFs almost never use the same driver as the PF so the warning
> is bogus there.
> 
What about the case where the VF driver IS the same as the PF driver?
