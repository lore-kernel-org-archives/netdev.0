From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Tue, 6 Dec 2011 13:15:43 +0000
Message-ID: <CAJSP0QXsLwvH5xYj6h0E_V4VLg6DuUc-GKXu9esEYzL2MFcFGw@mail.gmail.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
	<4EDDB71F.9080908@redhat.com>
	<CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
	<4EDDECA9.8060808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40484 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386Ab1LFNPp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 08:15:45 -0500
In-Reply-To: <4EDDECA9.8060808@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 6, 2011 at 10:21 AM, Jason Wang <jasowang@redhat.com> wrote=
:
> On 12/06/2011 05:18 PM, Stefan Hajnoczi wrote:
>>
>> On Tue, Dec 6, 2011 at 6:33 AM, Jason Wang<jasowang@redhat.com> =A0w=
rote:
>>>
>>> On 12/05/2011 06:55 PM, Stefan Hajnoczi wrote:
>>>>
>>>> On Mon, Dec 5, 2011 at 8:59 AM, Jason Wang<jasowang@redhat.com>
>>>> =A0wrote:
>> The vcpus are just threads and may not be bound to physical CPUs, so
>> what is the big picture here? =A0Is the guest even in the position t=
o
>> set the best queue mappings today?
>
>
> Not sure it could publish the best mapping but the idea is to make su=
re the
> packets of a flow were handled by the same guest vcpu and may be the =
same
> vhost thread in order to eliminate the packet reordering and lock
> contention. But this assumption does not take the bouncing of vhost o=
r vcpu
> threads which would also affect the result.

Okay, this is why I'd like to know what the big picture here is.  What
solution are you proposing?  How are we going to have everything from
guest application, guest kernel, host threads, and host NIC driver
play along so we get the right steering up the entire stack.  I think
there needs to be an answer to that before changing virtio-net to add
any steering mechanism.

Stefan
