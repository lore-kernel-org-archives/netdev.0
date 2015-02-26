From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 06:22:52 -0500
Message-ID: <20150226112252.GF9840@oracle.com>
References: <20150226074214.GF2074@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, jpettit@nicira.com,
	joestringer@nicira.com, john.r.fastabend@intel.com,
	jhs@mojatatu.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	simon.horman@netronome.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22720 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbbBZLXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 06:23:44 -0500
Content-Disposition: inline
In-Reply-To: <20150226074214.GF2074@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/26/15 08:42), Jiri Pirko wrote:
> 6) implement "named sockets" (working name) and implement TC support for that
>     -ingress qdisc attach, act_mirred target
> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets

Can you elaborate a bit on the above two?

FWIW I've been looking at the problem of RDS over TCP, which is
an instance of layered sockets that tunnels the application payload
in TCP. 

RDS over IB provides QoS support using the features available in
IB- to supply an analog of that for RDS-TCP, you'd need to plug
into tc's CBQ support, and also provide hooks for packet (.1p, dscp)
marking. 

Perhaps there is some overlap to what you are thinking of in #6 and #7 
above?

--Sowmini
