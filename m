From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Fri, 2 Jun 2006 11:37:53 -0600
Message-ID: <20060602113753.A20836@openss7.org>
References: <20060531090301.GA26782@2ka.mipt.ru> <20060531035124.B3065@openss7.org> <20060531105814.GB7806@2ka.mipt.ru> <20060531.114127.14356069.davem@davemloft.net> <20060601060424.GA28087@2ka.mipt.ru> <87y7wgaze1.fsf@mid.deneb.enyo.de> <20060602074845.GA17798@2ka.mipt.ru> <87ac8v8o4i.fsf@mid.deneb.enyo.de>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:54470 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S1751348AbWFBRhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 13:37:54 -0400
To: Florian Weimer <fw@deneb.enyo.de>
Content-Disposition: inline
In-Reply-To: <87ac8v8o4i.fsf@mid.deneb.enyo.de>; from fw@deneb.enyo.de on Fri, Jun 02, 2006 at 07:26:53PM +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian,

On Fri, 02 Jun 2006, Florian Weimer wrote:
> 
> I see them now.  Hmm.  Is there a theoretical explanation for them?

Jenkins is an ad hoc function that is far from ideal.  As you know,
the ideal hash changes 1/2 the bits in the output value for each one
bit change in the input value(s).  Jenkins changes a few as 1/3 and
performs less than ideal over even a small smaple of the input data
set (Jenkins said he checked several billion of the trilions of
changes).

It should not be suprising that a general purpose ad hoc function
(Jenkins) performs poorer than a specific purpose ad hoc function
(XOR), for the very specific input data sets that the later was chosen
to cover.

Theoretically, XOR can be improved upon, but Jenkins doesn't do it.
