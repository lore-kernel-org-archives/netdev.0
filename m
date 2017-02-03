From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] mpls: allow TTL propagation to/from IP packets
 to be configured
Date: Thu, 2 Feb 2017 21:02:47 -0700
Message-ID: <bffe7633-9285-bd2a-8cfa-3b0918ca62ce@cumulusnetworks.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
 <878tpst75o.fsf@xmission.com>
 <9aff4996-3e8e-66e3-c806-80b3947fcf08@brocade.com>
 <87bmukhscc.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        Robert Shearman <rshearma@brocade.com>,
        roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33435 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbdBCECu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:02:50 -0500
Received: by mail-pg0-f50.google.com with SMTP id 204so2851763pge.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 20:02:49 -0800 (PST)
In-Reply-To: <87bmukhscc.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/17 8:21 PM, Eric W. Biederman wrote:
> 
> My brain is mostly elswhere right now so I don't have an implementation
> on how it should be implemented.   However Linux fundamentally gets used
> interesting ways, and if we don't implement the option as per mpls exit
> now someone will come along and need to do the work later.
> 
> Perhaps it will only be used with hard coded static configurations, and
> it is fundamentally a per tunnel property.
> 
> It will be less work to maintain, and the code will run faster in the
> long run if we don't have two code paths to maintain.

I can see the argument for per-tunnel knobs, but looking at ios and nx-os docs it seems appropriate to have a global knob as well. In that regards having sysctl knobs solves the global setting and when/if needed we can add MPLS_IPTUNNEL_ZZZZZ encap attributes for the per-tunnel settings.

Does that seem reasonable?
