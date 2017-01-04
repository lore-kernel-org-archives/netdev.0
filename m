From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net-next 1/2] tools: psock_lib: tighten conditions
 checked in sock_setfilter
Date: Wed, 4 Jan 2017 17:55:54 -0500
Message-ID: <20170104225554.GD31756@oracle.com>
References: <cover.1483555162.git.sowmini.varadhan@oracle.com>
 <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com>
 <d3e75147-475a-823c-3530-5150dd24a63d@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, willemb@google.com, davem@davemloft.net
To: Shuah Khan <shuah@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:19994 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032093AbdADW5w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 17:57:52 -0500
Content-Disposition: inline
In-Reply-To: <d3e75147-475a-823c-3530-5150dd24a63d@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/04/17 15:37), Shuah Khan wrote:
> > +	/* the filter below checks for all of the following conditions that
> > +	 * are based on the contents of create_payload()
> > +	 *  ether type 0x800 and
> > +	 *  ip proto udp     and
> > +	 *  ip len == ip_len and
> > +	 *  udp[38] == 'a' or udp[38] == 'b'
> > +	 */
> 
> Looks like you have to do v4 anyway, please make sure your comment
> block is one of the acceptable formats based on coding style:
> 
> https://marc.info/?l=linux-crypto-vger&m=146799837129319&w=2

BTW, the above is conformant with the comment style required for
networking:

https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt

which seems to be used in psock_fanout.c and reuseport_bpf.c as well.

Thanks
--Sowmini
