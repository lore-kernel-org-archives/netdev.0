From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 4/6] openvswitch: Rename GENEVE_TUN_OPTS() to TUN_METADATA_OPTS()
Date: Mon, 12 Jan 2015 13:38:21 -0800
Message-ID: <CAEP_g=8GfXi-nhQ+n5P+QuxVoV9abm+2VsonvLQ1hCNP-oONNg@mail.gmail.com>
References: <cover.1421064100.git.tgraf@suug.ch> <c55f879e5dedb8ec3d6d06ce7d9d095e787e1c77.1421064100.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:44276 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750973AbbALVim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:38:42 -0500
Received: by mail-qg0-f53.google.com with SMTP id l89so19725038qgf.12
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:38:42 -0800 (PST)
In-Reply-To: <c55f879e5dedb8ec3d6d06ce7d9d095e787e1c77.1421064100.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index d1eecf7..8980d32 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> +static int validate_and_copy_geneve_opts(struct sw_flow_key *key)
> +{

This function doesn't actually do any copying, so maybe there is a
more descriptive name for it?
