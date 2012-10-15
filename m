From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: regression when connecting to ipv6 localhost
Date: Mon, 15 Oct 2012 11:07:43 +0200
Message-ID: <507BD25F.3080600@computer.org>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com> <1350242941.21172.17023.camel@edumazet-glaptop> <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com> <1350244485.21172.17077.camel@edumazet-glaptop> <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com> <1350246314.21172.17139.camel@edumazet-glaptop> <1350246414.21172.17144.camel@edumazet-glaptop> <1350246481.21172.17147.camel@edumazet-glaptop> <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com> <1350248858.21172.17197.camel@edumazet-glaptop> <CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com> <1350250542.21172.17229.camel@edumazet-glaptop> <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay009.isp.belgacom.be ([195.238.6.176]:20645 "EHLO
	mailrelay009.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751767Ab2JOJK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 05:10:26 -0400
In-Reply-To: <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2012 11:54 PM, Jan Hinnerk Stosch wrote:
> Ok, here is the strace output. I wonder whether this is enough as it
> exits very early - ntp still running though.

When starting, ntpd forks a copy and daemonises it. The original process
then parses the configuration file, passes the parsed configuration
incrementally to the daemon process and then exits.
