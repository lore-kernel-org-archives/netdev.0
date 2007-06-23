From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 05:50:11 +0100
Message-ID: <467CA683.2000706@simon.arlott.org.uk>
References: <OFB5D50B53.A24A00A2-ON88257303.0017FE53-88257303.0018AD5D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "C. Scott Ananian" <cscott@laptop.org>, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:52206 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbXFWEuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 00:50:18 -0400
In-Reply-To: <OFB5D50B53.A24A00A2-ON88257303.0017FE53-88257303.0018AD5D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/06/07 05:30, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 06/22/2007 06:17:46 PM:
Is there a reason why you're CC:ing the Sender? Doesn't that end 
up in the mailbox(es) of the netdev admin(s)?

>> On 23/06/07 02:04, David Stevens wrote:
>>>         Why not make the application that writes resolv.conf
>>> also listen on a raw ICMPv6 socket? I don't believe you'd need
>>> any kernel changes, then, and it seems pretty simple and
>>> straightforward.
>> Because then it requires yet another network daemon, RA in 
>> the kernel means there's no need for one to manage adding 
>> auto-configured IP addresses... what's wrong with doing the 
>> same for DNS?
> 
>         It's not yet another one, since you have to run something
> to get it in resolv.conf, anyway. That seems much better to me

Well, it'd be the library including it - so there'd be no daemon 
application involved.

> than having the kernel track data that can only be used at the
> application layer. The app itself looks like it'd be really simple.

Keeping application data in the kernel does start to get silly though, 
e.g. everything in dhcp-options(5)... but DNS is used almost 
everywhere. This could be a configuration option so that anyone who 
doesn't want it can disable it completely.

>         Auto-configured addresses are used by the kernel. It has to
> have those addresses. But the kernel doesn't do DNS look-ups, or
> write resolv.conf; that's the difference, for me.

Using DHCPv6 as an example, auto-configuration does not have to be in 
the kernel at all either.

-- 
Simon Arlott
