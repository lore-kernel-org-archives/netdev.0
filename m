From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Only set TUNNEL_VXLAN_OPT if
 VXLAN-GBP metadata is set
Date: Mon, 9 Feb 2015 09:59:40 -0800
Message-ID: <CALnjE+q-LG__puApG9_1ywrUgo-Kpaove8TZwZoti7ztChpe+w@mail.gmail.com>
References: <27de6976a7a40d1da2875b93138353724cbfa24b.1423497309.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aob139.obsmtp.com ([74.125.149.251]:51452 "HELO
	psmtp.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933546AbbBIR7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 12:59:40 -0500
Received: by mail-ie0-f180.google.com with SMTP id rl12so18383817iec.11
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 09:59:40 -0800 (PST)
In-Reply-To: <27de6976a7a40d1da2875b93138353724cbfa24b.1423497309.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 9, 2015 at 7:56 AM, Thomas Graf <tgraf@suug.ch> wrote:
> This avoids setting TUNNEL_VXLAN_OPT for VXLAN frames which don't
> have any GBP metadata set. It is not invalid to set it but unnecessary.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.
