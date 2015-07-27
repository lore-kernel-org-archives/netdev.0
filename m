From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [patch net-next 4/4] mlxsw: Introduce Mellanox SwitchX-2 ASIC
 support
Date: Mon, 27 Jul 2015 06:17:22 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F919405E0B@HASMSX110.ger.corp.intel.com>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
 <1437666216-3149-5-git-send-email-jiri@resnulli.us>
 <CAE4R7bAk_nUCuqcJxuAAr6pOqNX7zXWv1zFZDVGwBi7_nk8=kQ@mail.gmail.com>
 <20150726071010.GA2150@nanopsycho.fritz.box>
 <20150726171410.GB2207@nanopsycho.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	John Linville <linville@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"Shrijeet Mukherjee" <shm@cumulusnetworks.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:9249 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbbG0GR3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 02:17:29 -0400
In-Reply-To: <20150726171410.GB2207@nanopsycho.fritz.box>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jiri,

Keep on the good work!

The .func  member of the mlxsw_rx_listener object has this prototype:
void (*func)(struct sk_buff *skb, u8 local_port, u16 trap_id, void *priv);

Is the trap_id  parameter needed ?
In the three use cases of .func, which are either mlxsw_emad_rx_listener_func(), mlxsw_core_event_listener_func(), or mlxsw_sx_rx_listener_func(), this parameter is not used at all.


Regards,
Rami Rosen
Intel Corporation
