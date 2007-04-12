From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: PROBLEM: tg3 spitting out uninitialized memory
Date: Thu, 12 Apr 2007 13:39:40 -0700
Message-ID: <1176410380.11425.5.camel@dell>
References: <461D57E9.3000300@jwebb.sygneca.com>
 <p73tzvl7ilg.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jamie webb" <j@jwebb.sygneca.com>, netdev@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4336 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965584AbXDLTzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 15:55:17 -0400
In-Reply-To: <p73tzvl7ilg.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-04-12 at 16:50 +0200, Andi Kleen wrote:
> Jamie webb <j@jwebb.sygneca.com> writes:
> 
> > Hi there
> > 
> > I have a Dell PE860 with built-in BCM5721, which is reported as
> > working fine with the tg3 driver, however I have been getting sporadic
> > data corruption, mostly evident as SSH MAC errors.
> 
> FWIW i also saw this (data corruption with tg3) occasionally,
> but never repeatable or with a packet dump.
> 
My suggestion is to try turning tx checksum off (ethtool -K eth0 tx off)
to see if it makes a difference.  I'm not aware of checksum problem on
5721, but it is worth trying.  See if the other end is reporting TCP
checksum errors also.

