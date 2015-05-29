From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] openvswitch: disable LRO
Date: Thu, 28 May 2015 17:56:25 -0700
Message-ID: <CALnjE+qKKkBmeynbeUb42smnQyFrRGfTw7M-hCB-mCyCKXm3fQ@mail.gmail.com>
References: <cf405251e71318f7c7f8ddac07919acb8c28232e.1432818254.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Jesse Gross <jesse@nicira.com>,
	Flavio Leitner <fbl@sysclose.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:52158 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755149AbbE2A40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 20:56:26 -0400
Received: by mail-ie0-f173.google.com with SMTP id j10so51299030iep.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 17:56:25 -0700 (PDT)
In-Reply-To: <cf405251e71318f7c7f8ddac07919acb8c28232e.1432818254.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 6:04 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Currently, openvswitch tries to disable LRO from the user space. This does
> not work correctly when the device added is a vlan interface, though.
> Instead of dealing with possibly complex stacked cross name space relations
> in the user space, do the same as bridging does and call dev_disable_lro in
> the kernel.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>
