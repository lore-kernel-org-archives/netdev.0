From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] net: Add l3mdev cgroup
Date: Mon, 4 Jan 2016 11:53:55 -0700
Message-ID: <568ABFC3.3010803@cumulusnetworks.com>
References: <1451925136-13327-1-git-send-email-dsa@cumulusnetworks.com>
 <20160104175836.GA11668@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	shm@cumulusnetworks.com, roopa@cumulusnetworks.com
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35859 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbcADSx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 13:53:58 -0500
Received: by mail-oi0-f54.google.com with SMTP id o62so255167248oif.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 10:53:58 -0800 (PST)
In-Reply-To: <20160104175836.GA11668@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tejun:

On 1/4/16 10:58 AM, Tejun Heo wrote:
> Please don't create any new controller whose sole purpose is
> identifying group membership.  Please take a look at how libxt_cgroup
> handles identification w/o creating a new controller.
>
>   http://lkml.kernel.org/g/1449527935-27056-1-git-send-email-tj@kernel.org
>

This controller applies a cgroup specific setting to tasks associated 
with an instance (similar to cpuset restricting tasks to specifics 
CPUs), so it is more than just identifying membership.

I looked at the commits referenced above and net/netfilter/xt_cgroup.c 
code in particular and I don't see how it applies to this use case. Can 
you elaborate?

Thanks,
David
