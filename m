From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 1/4] i40e/i40evf: Add capability exchange for outer checksum
Date: Fri, 7 Apr 2017 09:38:32 +0300
Message-ID: <CAJ3xEMho=LsCOsdbgKHJjTiYB55UR9ZnnZkMAqpM=kH=VGsnrg@mail.gmail.com>
References: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com> <20170407032325.33374-2-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Preethi Banala <preethi.banala@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        Alan Brady <alan.brady@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Jacob Keller <jacob.e.keller@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33697 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752954AbdDGGid (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 02:38:33 -0400
Received: by mail-oi0-f41.google.com with SMTP id b187so76309396oif.0
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 23:38:33 -0700 (PDT)
In-Reply-To: <20170407032325.33374-2-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 7, 2017 at 6:23 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Preethi Banala <preethi.banala@intel.com>
>
> This patch adds a capability negotiation between VF and PF using ENCAP/
> ENCAP_CSUM offload flags in order for the VF to support outer checksum
> and TSO offloads for encapsulated packets.

[...]
-#define I40E_VIRTCHNL_VF_OFFLOAD_    0X00100000
+#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP         0X00100000
+#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM    0X00200000

what happens when one of the PF or VF doesn't have this hunk, e.g one
assumes value X and one assumes value Y for ENCAP_CSUM
