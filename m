From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [patch] enic: cleanup vic_provinfo_alloc()
Date: Fri, 11 Jun 2010 17:05:37 -0700
Message-ID: <C8381D61.38957%scofeldm@cisco.com>
References: <20100610075903.GL5483@bicker>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:16874 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab0FLAGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 20:06:20 -0400
In-Reply-To: <20100610075903.GL5483@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/10/10 12:59 AM, "Dan Carpenter" <error27@gmail.com> wrote:

> If oui were a null variable then vic_provinfo_alloc() would leak memory.
> But this function is only called from one place and oui is not null so
> I removed the check.
> 
> I also moved the memory allocation down a line so it was easier to spot.
> (No one ever reads variable declarations).
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

We'll pick this one up and resubmit with the next enic patch bomb.  Thanks
Dan.

-scott

