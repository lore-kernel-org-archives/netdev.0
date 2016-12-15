From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC v2 02/10] IB/hfi-vnic: Virtual Network Interface
 Controller (VNIC) interface
Date: Thu, 15 Dec 2016 09:36:57 -0800
Message-ID: <20161215093657.00925c10@xeon-e3>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
        <1481788782-89964-3-git-send-email-niranjana.vishwanathapura@intel.com>
        <20161215085349.GA90068@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, dennis.dalessandro@intel.com,
        ira.weiny@intel.com
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:32908 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757250AbcLORhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 12:37:05 -0500
Received: by mail-pg0-f45.google.com with SMTP id 3so22165194pgd.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 09:37:05 -0800 (PST)
In-Reply-To: <20161215085349.GA90068@knc-06.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Dec 2016 00:53:49 -0800
"Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com> wrote:

> On Wed, Dec 14, 2016 at 11:59:34PM -0800, Vishwanathapura, Niranjana wrote:
> >+
> >+static inline bool is_hfi_ibdev(struct ib_device *ibdev)
> >+{
> >+	return !memcmp(ibdev->name, "hfi", 3);
> >+}  
> 
> I am thinking of adding a device capability flag to indicate HFI VNIC capabilty 
> instead of relying on the device name as above to identify a hfi ib deice.
> Any comments? Probably it can be addressed by a separate patch later.
> 
> Niranjana
> 
> >  

Agreed. device name can change at anytime.
