From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2/6] myri10ge - Add missing PCI IDs
Date: Wed, 10 May 2006 23:52:48 +0200
Message-ID: <200605102352.48453.ak@suse.de>
References: <446259A0.8050504@myri.com> <44625C92.8020209@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:12417 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751510AbWEJVwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 17:52:53 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <44625C92.8020209@myri.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 May 2006 23:35, Brice Goglin wrote:
> [PATCH 2/6] myri10ge - Add missing PCI IDs
> 
> Add nVidia nForce CK804 PCI-E bridge and 
> ServerWorks HT2000 PCI-E bridge IDs.
> They will be used by the myri10ge driver.

That's a bad sign. It means you have code in your driver 
that should be somewhere else.

-Andi
