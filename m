From: maowenan <maowenan@huawei.com>
Subject: RE: [PATCH] ethtool: add one ethtool option to set relax ordering
 mode
Date: Thu, 22 Dec 2016 01:39:09 +0000
Message-ID: <F95AC9340317A84688A5F0DF0246F3F20151F189@szxeml504-mbs.china.huawei.com>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
        <1481179898-10668-2-git-send-email-maowenan@huawei.com>
 <20161221172759.1bc0d0dd@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Dingtianhong <dingtianhong@huawei.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:35809 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756276AbcLVBj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 20:39:56 -0500
In-Reply-To: <20161221172759.1bc0d0dd@xeon-e3>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Thursday, December 22, 2016 9:28 AM
> To: maowenan
> Cc: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com
> Subject: Re: [PATCH] ethtool: add one ethtool option to set relax ordering mode
> 
> On Thu, 8 Dec 2016 14:51:38 +0800
> Mao Wenan <maowenan@huawei.com> wrote:
> 
> > This patch provides one way to set/unset IXGBE NIC TX and RX relax
> > ordering mode, which can be set by ethtool.
> > Relax ordering is one mode of 82599 NIC, to enable this mode can
> > enhance the performance for some cpu architecure.
> 
> Then it should be done by CPU architecture specific quirks (preferably in PCI
> layer) so that all users get the option without having to do manual intervention.
> 
> > example:
> > ethtool -s enp1s0f0 relaxorder off
> > ethtool -s enp1s0f0 relaxorder on
> 
> Doing it via ethtool is a developer API (for testing) not something that makes
> sense in production.


This feature is not mandatory for all users, acturally relax ordering default configuration of 82599 is 'disable',
So this patch gives one way to enable relax ordering to be selected in some performance condition.
