From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 4 Oct 2006 10:56:12 +0200
Message-ID: <200610041056.12704.netdev@axxeo.de>
References: <451AC889.5000407@redhat.com> <4522A88E.2070200@redhat.com> <20061004.000722.99203823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: woodard@redhat.com, netdev@vger.kernel.org, mgrondona@llnl.gov,
	behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:57055 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S964789AbWJDI41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 04:56:27 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061004.000722.99203823.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> At the very least, seconds might not be fine enough granularity
> for some circumstances.  Heck, the default RTO_MIN is 1/5 of a
> second. :-)
> 
> I also understand that going to milliseconds or microseconds would
> make the size of the in-socket struct members an issue again.  These
> things are never easy are they? :-/

Would be, if floating point values would be allowed. Single precision would 
be enough in this case and its just 32 bits IIRC.

I mean floating point values just for the user->kernel ABI and 
NOT for the internal timer representation.


Regards

Ingo Oeser
