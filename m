From: Rick Jones <rick.jones2@hp.com>
Subject: Re: GRO aggregation
Date: Wed, 12 Sep 2012 09:23:27 -0700
Message-ID: <5050B6FF.5050002@hp.com>
References: <504F4063.9030706@mellanox.com>  , <1347388396.13103.658.camel@edumazet-glaptop> <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com> , <1347390113.13103.660.camel@edumazet-glaptop> <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com> <1347392132.13103.663.camel@edumazet-glaptop> <505054AE.9040901@mellanox.com> <1347442394.13103.703.camel@edumazet-glaptop> <50509F30.30402@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shlomo Pongartz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:12928 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756885Ab2ILQX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 12:23:28 -0400
In-Reply-To: <50509F30.30402@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2012 07:41 AM, Shlomo Pongartz wrote:
> Hi Eric
>
> The TSO is just a mean to create a burst of frames on the wire so the
> NAPI will be able to pool as much as possible.

Is it?  If I recall correctly, TSO was in place well before all drivers 
were using NAPI.  And NAPI was being proposed independent of TSO. TSO is 
there to save CPU cycles on the transmit side.  "On the wire" what it 
sends is to be identical to what a host with greater CPU performance 
could accomplish.

rick jones
