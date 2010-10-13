From: Stefano Salsano <stefano.salsano@uniroma2.it>
Subject: Re: Question on DHCP
Date: Wed, 13 Oct 2010 09:31:34 +0200
Message-ID: <4CB56056.2040704@uniroma2.it>
References: <AANLkTikTKL2JzmHKUrraOoNdqV1=0e_r+EuvBTgURjUz@mail.gmail.com> <20101012184543.55ebf503@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Sri Ram Vemulpali <sri.ram.gmu06@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.uniroma2.it ([160.80.6.16]:46157 "EHLO smtp.uniroma2.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753148Ab0JMHlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 03:41:55 -0400
In-Reply-To: <20101012184543.55ebf503@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 12 Oct 2010 21:33:25 -0400
> Sri Ram Vemulpali <sri.ram.gmu06@gmail.com> wrote:
> 
>> Hi All,
>>
>>    I have very basic stupid doubt. Can anyone help to resolve this.
>>
>> DHCP, is used for dynamically configuring IP address, mask, MTU, DNS
>> domain, .... for a host. DHCP is a application layer protocol, but the
>> values it configures are related to IP layer. How come DHCP can
>> configure when its data packet in embedded in to IP datagram, which
>> are disparate layers. I am little confused. Please clarify. Thanks.
>>
> 
> DHCP client uses UDP to send broadcast packet and find the nearest
> server.  The Linux DHCP client ends up using a AF_PACKET socket because
> it wants to seem MAC address of server.

you may also want to refer to RFC 2131 (Dynamic Host Configuration 
Protocol), in section 2 it states:

In the case of a client using DHCP for initial configuration (before
    the client's TCP/IP software has been completely configured), DHCP
    requires creative use of the client's TCP/IP software and liberal
    interpretation of RFC 1122.  The TCP/IP software SHOULD accept and
    forward to the IP layer any IP packets delivered to the client's
    hardware address before the IP address is configured;

-- 
*******************************************************************
Stefano Salsano
Dipartimento Ingegneria Elettronica
Universita' di Roma "Tor Vergata"
Via del Politecnico, 1 - 00133 Roma - ITALY

http://netgroup.uniroma2.it/Stefano_Salsano/

E-mail  : stefano.salsano@uniroma2.it
Cell.   : +39 320 4307310
Office  : (Tel.) +39 06 72597770  (Fax.) +39 06 72597435
*******************************************************************
