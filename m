From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: updated tcatm patches for kernel/iproute 2.6.22
Date: Wed, 18 Jul 2007 23:39:15 +0100
Message-ID: <20070718233915.5c90a648@oldman>
References: <20070718210638.bs44zz4veowqf2kr@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Mailing List <netdev@vger.kernel.org>
To: Sami Farin <safari-kernel@safari.iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56441 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933733AbXGRWkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:40:01 -0400
In-Reply-To: <20070718210638.bs44zz4veowqf2kr@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 00:06:38 +0300
Sami Farin <safari-kernel@safari.iki.fi> wrote:

> I got tired of getting 15% packet loss [1] when doing
> lots of DNS lookups on my ADSL link...
> And that was even when limiting outgoing DNS traffic
> to 200 Kbit/s (ADSL modem upstream speed is 512 Kbit/s).
> 
> I had used tcatm patch with 2.6.16 kernel and I was
> happy with it.
> Now I patched Linux kernel 2.6.22 and iproute-2.6.22
> for tcatm.  Seems to work (TM).  Only HTB tested.
> 
> Now I get 0% packet loss when doing lots of DNS queries
> (270pps) and DNS traffic is limited with
> HTB/ESFQ to 504Kbit/s.  I used "tc class add ... atm overhead 20"
> but I am not sure is it really 20 (Sonera in Finland).
> Without tcatm I had to have there 420Kbit and it still sucked.
> 
> I keep patches at
> http://safari.iki.fi/tcatm/
> 
> I read one thread from this year where there were objections
> about tcatm's some parts and then discussion petered out...
> I and probably Russell Stuart would probably like to get
> these patches fixed so that everyone is pleased
> and these can be incorporated into kernel some year,
> because I believe ADSL is very popular nowadays ( =) )
> and people would probably like if traffic control was
> actually usable for them ( =) )...
> 
> [1] ping -A 80.223.96.1


My concern is that this would cause the existing users of TBF and
other qdisc's.  If you don't choose ATM do you get the same values?
