From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Question on DHCP
Date: Tue, 12 Oct 2010 18:45:43 -0700
Message-ID: <20101012184543.55ebf503@nehalam>
References: <AANLkTikTKL2JzmHKUrraOoNdqV1=0e_r+EuvBTgURjUz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Sri Ram Vemulpali <sri.ram.gmu06@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37963 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734Ab0JMBpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 21:45:45 -0400
In-Reply-To: <AANLkTikTKL2JzmHKUrraOoNdqV1=0e_r+EuvBTgURjUz@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Oct 2010 21:33:25 -0400
Sri Ram Vemulpali <sri.ram.gmu06@gmail.com> wrote:

> Hi All,
> 
>    I have very basic stupid doubt. Can anyone help to resolve this.
> 
> DHCP, is used for dynamically configuring IP address, mask, MTU, DNS
> domain, .... for a host. DHCP is a application layer protocol, but the
> values it configures are related to IP layer. How come DHCP can
> configure when its data packet in embedded in to IP datagram, which
> are disparate layers. I am little confused. Please clarify. Thanks.
> 

DHCP client uses UDP to send broadcast packet and find the nearest
server.  The Linux DHCP client ends up using a AF_PACKET socket because
it wants to seem MAC address of server.

-- 
