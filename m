From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 1/2] virtio-net: Verify page list size before fitting into skb
Date: Mon, 26 Sep 2011 23:04:39 +0300
Message-ID: <CAOJsxLGQ-2y7eQy94F=yj5v9T_Gn-ZgD_1reOsV_Gqrfb7rgKQ@mail.gmail.com>
References: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
	<20110926184445.GA22278@redhat.com>
	<1317065842.20885.3.camel@lappy>
	<CAOJsxLHQZCvRQMcs08GZgDgR9AwtePdr=t7kos6XfMF_dgxZGw@mail.gmail.com>
	<20110926195716.GB23086@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sasha Levin <levinsasha928@gmail.com>,
	linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110926195716.GB23086@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 26, 2011 at 10:45:35PM +0300, Pekka Enberg wrote:
>> I'm not sure what Michael means with "theoretical issue" here. Can the guest
>> driver assume that the hypervisor doesn't attempt to do nasty things?

On Mon, Sep 26, 2011 at 10:57 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> IMO yes, hypervisor has full access to guest memory so it's a safe
> assumption. But surviving in the face of hypervisor bugs
> is laudable goal, bugs do happen.

I was thinking of a compromised guest that is able to trick the hypervisor into
doing nasty things to other guests without taking over the hypervisor
completely. So for something like virtio networking, that's by
definition exposed
to rest of the world, I think it's very important not to be robust
against hypervisor
bugs.

In any case, we were able to trigger this particular case rather easily with our
buggy tool, so it's definitely worth fixing. ;-)

FWIW,

Acked-by: Pekka Enberg <penberg@kernel.org>

                                Pekka
