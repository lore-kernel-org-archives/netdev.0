From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: Invalid truesize messages since 2.6.25
Date: Tue, 22 Jul 2008 14:06:50 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13C73B02@exch.facton.local>
References: <3C59DB883F7B0B4D8096010D45ACCD13C73AFA@exch.facton.local> <20080722114311.GQ10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:39153 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbYGVMGz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 08:06:55 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080722114311.GQ10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Since 2.6.25 we rarely see these messages:
>> 
>> SKB BUG: Invalid truesize (408) len=198, sizeof(sk_buff)=216
>> 
>> Yesterday I saw it the first time after a runtime of one week with
>> 2.6.26.
>> The box is web server / IPSEC gateway.
>> Obviously nothing seems to be affected by the message but <= 2.6.24
no
>> messages appeared.

> Invalid truesize can be caused by bugs in many different places.  So
it
> might be helpful to say which driver(s) and any unusual network
protocol
> or filter you are using.

Network driver: tg3
IPSEC: esp tunnels, ipcomp, 3des/aes
I use this config so far on other servers too without this message.

The unusal part special to this server may be:
Bandwidth management via htb & sfq, CONFIG_IP_MULTIPLE_TABLES for source
IP routing

Daniel
