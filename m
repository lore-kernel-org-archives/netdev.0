From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Fri, 18 Apr 2008 08:45:27 -0400
Message-ID: <1208522727.4422.79.camel@localhost>
References: <20080417103858.0075236b@extreme>
	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>
	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>
	 <1208467480.15888.50.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:48438 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbYDRMpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 08:45:39 -0400
Received: by an-out-0708.google.com with SMTP id d31so141726and.103
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 05:45:38 -0700 (PDT)
In-Reply-To: <1208467480.15888.50.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Scanning that region of u32 that changed:
show_key() certainly assumes IPv4 (it will fail if we filter on IPV6,
ARP etc). I think this is even more reason to do the cooked variant as
the non-default.
Let me know if you are ok with changing that and i will invest time
"cooking" patches ;-> 

BTW, speaking of scripts and command line output changes (and to
emphasize my earlier comments):
A lot of people managing router configuration out there in the wild do
write parsers that depend on how output looks like (typically a
send/expect interaction)[1]. They invest time in writting such scripts.
In an old job at one point, a customer was adamant they wouldnt buy our
new super-dupper device merely because we changed the command output by
iirc removing a ":" in one of them. Theyd have to rewrite things and go
through whole regression testing.

cheers,
jamal
[1] Contrary to popular theory that provider use SNMP to do router
config (as found out by some study related to the IETF). Things are
changing a little with newer protocols showing up at the IETF to address
these sort of issues.

