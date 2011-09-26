From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH 1/2] virtio-net: Verify page list size before fitting
 into skb
Date: Mon, 26 Sep 2011 22:57:35 +0300
Message-ID: <1317067055.20885.5.camel@lappy>
References: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
	 <20110926184445.GA22278@redhat.com> <1317065842.20885.3.camel@lappy>
	 <CAOJsxLHQZCvRQMcs08GZgDgR9AwtePdr=t7kos6XfMF_dgxZGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37829 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab1IZT60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 15:58:26 -0400
In-Reply-To: <CAOJsxLHQZCvRQMcs08GZgDgR9AwtePdr=t7kos6XfMF_dgxZGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-26 at 22:45 +0300, Pekka Enberg wrote:
> On Mon, Sep 26, 2011 at 10:37 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
> >> Interesting.  This is a theoretical issue, correct?
> >> Not a crash you actually see.
> >
> > Actually it was an actual crash caused when our virtio-net driver in kvm
> > tools did funny things and passed '(u32)-1' length as a buffer length to
> > the guest kernel.
> 
> I'm not sure what Michael means with "theoretical issue" here. Can the guest
> driver assume that the hypervisor doesn't attempt to do nasty things?

afaik if the hypervisor can access the vcpus and the memory of the
guest, this shouldn't be a security issue - more of a bug prevention
issue.

I guess it'll be interesting the other way around, when it's the guest
that passes this buggy information to the hypervisor.

-- 

Sasha.
