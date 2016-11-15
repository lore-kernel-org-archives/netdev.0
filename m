From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver
 framework.
Date: Tue, 15 Nov 2016 08:21:50 +0100
Message-ID: <b6d4767e-47e2-a265-c4f8-5081a273b819@suse.de>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
 <1478588223-16183-4-git-send-email-manish.rangankar@cavium.com>
 <d5abc303-1514-c521-390c-adfdd0e204af@suse.de>
 <D450A21F.3537A%manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Dept-Eng QLogic Storage Upstream
        <QLogic-Storage-Upstream@cavium.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
To: "Rangankar, Manish" <Manish.Rangankar@cavium.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        "lduncan@suse.com" <lduncan@suse.com>,
        Chris Leech <cleech@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44698 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933542AbcKOHVx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 02:21:53 -0500
In-Reply-To: <D450A21F.3537A%manish.rangankar@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2016 07:14 AM, Rangankar, Manish wrote:
> Hi Hannes,
> 
> Please find the response below,
> 
> On 11/11/16 10:13 PM, "Hannes Reinecke" <hare@suse.de> wrote:
> 
[ .. ]
>> Please use the irq-affinity rework from Christoph here; that'll save you
>> the additional msix vectors allocation.
> 
> The existing qed* driver(s) and common module (qed) framework is built on
> top of the older pci_enable_msix_*() API. The new framework requires
> re-work on the existing qed common module API. That would need
> co-ordination among other dependent drivers (e.g.: qede network driver,
> which is already in the tree). We would prefer to add this as a follow on
> (to the initial submission) effort, with additional testing done and
> submission co-ordinated across protocol drivers.
> 
Ok, fair enough.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare@suse.de			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: F. Imendörffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG Nürnberg)
