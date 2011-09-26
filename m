From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 1/2] virtio-net: Verify page list size before fitting into skb
Date: Mon, 26 Sep 2011 22:45:35 +0300
Message-ID: <CAOJsxLHQZCvRQMcs08GZgDgR9AwtePdr=t7kos6XfMF_dgxZGw@mail.gmail.com>
References: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
	<20110926184445.GA22278@redhat.com>
	<1317065842.20885.3.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34540 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab1IZTpg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 15:45:36 -0400
In-Reply-To: <1317065842.20885.3.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2011 at 10:37 PM, Sasha Levin <levinsasha928@gmail.com>=
 wrote:
>> Interesting. =A0This is a theoretical issue, correct?
>> Not a crash you actually see.
>
> Actually it was an actual crash caused when our virtio-net driver in =
kvm
> tools did funny things and passed '(u32)-1' length as a buffer length=
 to
> the guest kernel.

I'm not sure what Michael means with "theoretical issue" here. Can the =
guest
driver assume that the hypervisor doesn't attempt to do nasty things?

                          Pekka
