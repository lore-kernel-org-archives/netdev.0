From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 07:00:40 -0700
Message-ID: <e9c3a7c20707240700o51362addm7c8398b83a539d56@mail.gmail.com>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <20070723132431.42afbae8.akpm@linux-foundation.org>
	 <20070723204045.GD5755@martell.zuzino.mipt.ru>
	 <20070723210153.GA5753@martell.zuzino.mipt.ru>
	 <20070723141137.171e4ac1.akpm@linux-foundation.org>
	 <20070723220446.GA5822@martell.zuzino.mipt.ru>
	 <20070723152712.02ded067.akpm@linux-foundation.org>
	 <20070724081750.GM3287@kernel.dk> <20070724082207.GN3287@kernel.dk>
	 <20070724013455.691e6752.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jens Axboe" <jens.axboe@oracle.com>,
	"Alexey Dobriyan" <adobriyan@gmail.com>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mark.fasheh@oracle.com,
	"Nelson, Shannon" <shannon.nelson@intel.com>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:31811 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754504AbXGXOAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 10:00:40 -0400
Received: by an-out-0708.google.com with SMTP id d31so377988and
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 07:00:40 -0700 (PDT)
In-Reply-To: <20070724013455.691e6752.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/24/07, Andrew Morton <akpm@linux-foundation.org> wrote:
[...]
> > What about the new async crypto stuff? I've been looking, but is it
> > guarenteed that async_memcpy() runs in process context with interrupts
> > enabled always? If not, there's a km type bug there.
>
> I think Shannon maintains that now.
>

I am looking after the async_tx API, I will send a patch to update
MAINTAINERS shortly.

--
Dan
