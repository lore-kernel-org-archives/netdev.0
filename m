From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] 9p: disconnect channel when PCI device is removed
Date: Mon, 07 May 2012 12:45:16 +0930
Message-ID: <87397chebf.fsf@rustcorp.com.au>
References: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, Sasha Levin <levinsasha928@gmail.com>
To: Sasha Levin <levinsasha928@gmail.com>, davem@davemloft.net,
	ericvh@gmail.com, aneesh.kumar@linux.vnet.ibm.com,
	jvrao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51537 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973Ab2EGFYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 01:24:17 -0400
In-Reply-To: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Apr 2012 17:48:36 -0400, Sasha Levin <levinsasha928@gmail.com> wrote:
> When a virtio_9p pci device is being removed, we should close down any
> active channels and free up resources, we're not supposed to BUG() if there's
> still an open channel since it's a valid case when removing the PCI device.
> 
> Otherwise, removing the PCI device with an open channel would cause the
> following BUG():

(Damn changed notmuch.el bindings!  Previous reply went only to Sasha).

Applied thanks,
Rusty.
