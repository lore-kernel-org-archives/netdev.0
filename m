From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 14/17] kvm: add a reset capability
Date: Tue, 31 Mar 2009 22:22:51 +0300
Message-ID: <49D26D8B.7020201@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184400.28333.50396.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34109 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573AbZCaTXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 15:23:12 -0400
In-Reply-To: <20090331184400.28333.50396.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:
> We need a way to detect if a VM is reset later in the series, so lets
> add a capability for userspace to signal a VM reset down to the kernel.
>   

How do you handle the case of a guest calling kexec to load a new 
kernel?  Or is that not important for your use case?

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

