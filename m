From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net v2] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Thu, 18 Feb 2016 07:31:45 -0800
Message-ID: <CAEh+42jrerZ=b3Tj08ekCBAnf+K4zEbZWio+p=KLoBwMXpxSbw@mail.gmail.com>
References: <244994c83cb73d98205f39aaefcee846dab48260.1455731463.git.pabeni@redhat.com>
 <CAEh+42isC=4nmKz-Sjc9VreCbOkqdEcPc2uXyxcgGRJQsdSWSw@mail.gmail.com> <1455788524.29084.8.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Benc <jbenc@redhat.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:60048 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752464AbcBRPcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 10:32:03 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 87BDA20382
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 15:32:02 +0000 (UTC)
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 322F4202FF
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 15:32:01 +0000 (UTC)
Received: by mail-qg0-f42.google.com with SMTP id b35so39093780qge.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 07:32:01 -0800 (PST)
In-Reply-To: <1455788524.29084.8.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 1:42 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Wed, 2016-02-17 at 11:19 -0800, Jesse Gross wrote:
>> On Wed, Feb 17, 2016 at 10:30 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>> > the commit 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be
>> > correctly controlled.") changed the default xmit checksum setting
>> > for lwt vxlan/geneve ipv6 tunnels, so that now the checksum is not
>> > set into external UDP header.
>> > This commit changes the rx checksum setting for both lwt vxlan/geneve
>> > devices created by openvswitch accordingly, so that lwt over ipv6
>> > tunnel pairs are again able to communicate with default values.
>> >
>> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>>
>> This is compat code that is being changed here. Based on the previous
>> discussion, shouldn't these be made the default for all users?
>
> This change was initially aimed at a smaller scope: use self consistent
> default for ovs lwt devices/tunnel terminations.
>
> If there is agreement, I can post a separate patch changing the default
> rx checksum setting for plain vxlan and geneve[1] devices tunneling over
> ipv6.

OK. I think it's important to do the followup to keep things
consistent but this is fine to start.

Acked-by: Jesse Gross <jesse@kernel.org>
