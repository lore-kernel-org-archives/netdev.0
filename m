From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: crash when setting ovs instance over net-next
Date: Thu, 5 Feb 2015 09:57:58 -0800
Message-ID: <CALnjE+p8cf1x_FeVNoWEsfnv-gNPGcOXR2Q8YYaS62gSbgY+Wg@mail.gmail.com>
References: <54D31C9D.9040607@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:42777 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751191AbbBER6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 12:58:07 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so46082793igb.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 09:57:58 -0800 (PST)
In-Reply-To: <54D31C9D.9040607@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 11:32 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> With latest net-next (commit 06eb395 "pkt_sched: fq: better control of DDOS
> traffic")
> under the below config [2], I see this crash [1], will send you also my
> .config
>
> The user-space bits are openvswitch-2.0.90-1 rpm built from the git.
>
> Or.
>

Thanks for the report. I sent out fix "openvswitch: Initialize
unmasked key and uid len"
