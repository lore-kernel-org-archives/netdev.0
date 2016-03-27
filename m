From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v1 1/1] lib/utils: fix get_addr() and
 get_prefix() error messages
Date: Sun, 27 Mar 2016 11:02:15 -0700
Message-ID: <20160327110215.44f62214@xeon-e3>
References: <C4896FB061E7DE4AAC93031BDCA044B11A2146FF@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"Szczerbik, PrzemyslawX" <przemyslawx.szczerbik@intel.com>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33177 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbcC0SB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 14:01:59 -0400
Received: by mail-pa0-f42.google.com with SMTP id fl4so81475308pad.0
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 11:01:59 -0700 (PDT)
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B11A2146FF@IRSMSX108.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Mar 2016 13:02:02 +0000
"Varlese, Marco" <marco.varlese@intel.com> wrote:

> An attempt to add invalid address to interface would print "???" string
> instead of the address family name.
> 
> For example:
> $ ip address add 256.10.166.1/24 dev ens8
> Error: ??? prefix is expected rather than "256.10.166.1/24".
> 
> $ ip neighbor add proxy 2001:db8::g dev ens8
> Error: ??? address is expected rather than "2001:db8::g".
> 
> With this patch the output will look like:
> $ ip address add 256.10.166.1/24 dev ens8
> Error: inet prefix is expected rather than "256.10.166.1/24".
> 
> $ ip neighbor add proxy 2001:db8::g dev ens8
> Error: inet6 address is expected rather than "2001:db8::g".
> 
> Signed-off-by: Przemyslaw Szczerbik <przemyslawx.szczerbik@intel.com>
> Signed-off-by: Marco Varlese <marco.varlese@intel.com>

Since this was so trivial, I did change manually since patch was corrupted.
