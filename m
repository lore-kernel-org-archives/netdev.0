From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 09:44:44 +0200
Message-ID: <1295ed070903120044s63b4da71i68add51703952d0f@mail.gmail.com>
References: <1236772642-12705-1-git-send-email-pktoss@gmail.com>
	 <200903121759.31024.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:33074 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbZCLHos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 03:44:48 -0400
Received: by ewy25 with SMTP id 25so257919ewy.37
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 00:44:45 -0700 (PDT)
In-Reply-To: <200903121759.31024.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 9:29 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> On Wednesday 11 March 2009 22:27:22 Pantelis Koukousoulas wrote:
>> For now the semantics are simple: There is always carrier.
>>
>> This allows a seamless experience with e.g., qemu/kvm
>> where NetworkManager just configures and sets up
>> everything automagically.
>
> So, NetworkManager ignores the device because it doesn't support
> carrier detection?

It doesn't ignore it, it just doesn't enable it by default, like it does for
those that do report carrier.

But the user experience is that on real hardware you just boot a livecd
and see your network "just working" (and the familiar icon with the 2
computers indicating that), while under e.g., KVM/virtio you get
non-working network / an icon with a red X and you have to
figure out to left click on it and select eth0 to get things to work.

Some newer versions of NetworkManager seem to assume that
if no carrier detection is supported then carrier is on by default
so it should work for those, but that assumption seems like
a worse hack than this patch :)

(And in any case this patch helps all those who don't run
the latest unstable branch of their distro, while causing
no harm as far as I can see)

Pantelis
