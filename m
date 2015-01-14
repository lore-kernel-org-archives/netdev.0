From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] openvswitch: packet messages need their own probe attribtue
Date: Wed, 14 Jan 2015 12:40:44 -0800
Message-ID: <CAEP_g=_Z_OUyNU=_ctFDAgLR=yDjsO_L4tNLSzGS=7oir39uVw@mail.gmail.com>
References: <1645184106.20150114131420@eikelenboom.it> <20150114130005.GA564@casper.infradead.org>
 <20150114130351.GB13716@breakpoint.cc> <20150114135619.GC564@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Pravin B Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Jarno Rajahalme <jrajahalme@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:60797 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751225AbbANUlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 15:41:06 -0500
Received: by mail-qg0-f49.google.com with SMTP id f51so8805129qge.8
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 12:41:04 -0800 (PST)
In-Reply-To: <20150114135619.GC564@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 5:56 AM, Thomas Graf <tgraf@suug.ch> wrote:
> User space is currently sending a OVS_FLOW_ATTR_PROBE for both flow
> and packet messages. This leads to an out-of-bounds access in
> ovs_packet_cmd_execute() because OVS_FLOW_ATTR_PROBE >
> OVS_PACKET_ATTR_MAX.
>
> Introduce a new OVS_PACKET_ATTR_PROBE with the same numeric value
> as OVS_FLOW_ATTR_PROBE to grow the range of accepted packet attributes
> while maintaining to be binary compatible with existing OVS binaries.
>
> Fixes: 05da589 ("openvswitch: Add support for OVS_FLOW_ATTR_PROBE.")
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Tracked-down-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This is kind of a nasty bug, thanks for fixing it.

Reviewed-by: Jesse Gross <jesse@nicira.com>
