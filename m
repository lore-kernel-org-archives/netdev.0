From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [questions] why doesn't BCM5788 driver use MSI? What should
 I do to enable it?
Date: Wed, 21 Jan 2009 08:59:31 -0800
Message-ID: <C27F8246C663564A84BB7AB343977242163420403C@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <df9815e70901210049j75979a1cm702a4da15e54a3e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Jike Song'" <albcamus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2765 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527AbZAUQ7k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 11:59:40 -0500
In-Reply-To: <df9815e70901210049j75979a1cm702a4da15e54a3e@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jike Song wrote:

> Is there any method to get BCM5788 (tg3 driver) work with MSI enabled?
> lspci tells me MSI is supported by BCM5788 card:
>

The capability is there, but the hardware implementation is buggy.
The interrupt cannot be properly disabled, among other issues.  MSI
was fixed in later versions of the PCIE chips.

