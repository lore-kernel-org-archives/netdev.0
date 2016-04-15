From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next 05/18] mlxsw: spectrum_buffers: Push out
 indexes and direction out of SB structs
Date: Fri, 15 Apr 2016 15:16:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4A31C7@AcuExch.aculab.com>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
 <1460650770-19382-6-git-send-email-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6D5F4A2E99@AcuExch.aculab.com>
 <20160415085259.GB1911@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"rami.rosen@intel.com" <rami.rosen@intel.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>
To: 'Jiri Pirko' <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:61455 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbcDOPRP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 11:17:15 -0400
In-Reply-To: <20160415085259.GB1911@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
> Sent: 15 April 2016 09:53
..
> >> @@ -106,10 +96,9 @@ static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
> >>  	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port,
> >>  			    0xffff, 0xffff / 2);
> >>  	for (i = 0; i < MLXSW_SP_PBS_LEN; i++) {
> >
> >I'd rather see an explicit ARRAY_COUNT(mlxsw_sp_pbs) than some 'randon' constant.
> 
> See "#define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)"

Imagine I'm reading the code quickly.
If the for() loop uses ARRAY_COUNT(mlxsw_sp_pbs) then (provided I grok ARRAY_COUNT())
I know that the array bounds are honoured.
When it uses MLXSW_SP_PBS_LEN I have to search for the definition in order
to check that it is the correct value/constant for that array.

	David
