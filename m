From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
 mapping
Date: Fri, 16 Jul 2010 12:33:06 -0700 (PDT)
Message-ID: <20100716.123306.232886890.davem@davemloft.net>
References: <D3F292ADF945FB49B35E96C94C2061B90C55C202@nsmail.netscout.com>
	<20100716113113.1e2b51c7@nehalam>
	<AANLkTin3V7LtmhDAOktNF1UITM86sJwButxCQ3vo31lv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, Chetan.Loke@netscout.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: chetanloke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41279
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754806Ab0GPTcv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 15:32:51 -0400
In-Reply-To: <AANLkTin3V7LtmhDAOktNF1UITM86sJwButxCQ3vo31lv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Chetan Loke <chetanloke@gmail.com>
Date: Fri, 16 Jul 2010 15:29:06 -0400

> On Fri, Jul 16, 2010 at 2:31 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
>> Simple way:
>> =A0 Use SIOCGIFCONF to get list of interfaces
>> =A0 Use SIOCGIFHWADDR to read device addresss
>>
> And interfaces that don't have IP's?

There is no requirement that an interface have configured IP addresses
in order to use those ioctl()'s.

You simply create an arbitrary socket, and use the resulting 'fd' to
run the ioctl's mentioned to fetch information about any and all
interfaces which exist in the system.
