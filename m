From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: UDP sockets bound to ANY send answers with wrong src ip address
Date: Wed, 09 Jun 2004 21:24:30 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040609.212430.123946645.yoshfuji@linux-ipv6.org>
References: <200406091425.39324.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com,
        pekkas@netcore.fi, jmorris@redhat.com, linux-kernel@vger.kernel.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vda@port.imtp.ilyichevsk.odessa.ua
In-Reply-To: <200406091425.39324.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200406091425.39324.vda@port.imtp.ilyichevsk.odessa.ua> (at Wed, 9 Jun 2004 14:25:39 +0300), Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> says:

> I observe that UDP sockets listening on ANY
> send response packets with ip addr derived from
> ip address of interface which is used to send 'em
> instead of using dst ip address of client's packet.

use IP_PKTINFO when responding the client.

--yoshfuji
