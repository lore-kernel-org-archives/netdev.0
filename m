From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v1 1/1] lib/utils: fix get_addr() and
 get_prefix() error messages
Date: Wed, 30 Mar 2016 16:54:20 -0700
Message-ID: <20160330165420.36f98115@xeon-e3>
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
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33142 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbcC3XyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 19:54:06 -0400
Received: by mail-pf0-f176.google.com with SMTP id 4so54734103pfd.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 16:54:05 -0700 (PDT)
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
> ---
> lib/utils.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)

If you look at git, I already applied this by manual fix.
