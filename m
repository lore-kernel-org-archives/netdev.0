From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 26 Nov 2012 09:33:05 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70BE@saturn3.aculab.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-80-git-send-email-wfp5p@virginia.edu> <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org> <alpine.LFD.2.02.1211191912040.25230@eddie.linux-mips.org> <20121119192949.GA16976@kroah.com> <alpine.LFD.2.02.1211212334080.25230@eddie.linux-mips.org> <20121122002337.GA16151@kroah.com> <alpine.LFD.2.02.1211260425240.25230@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Bill Pemberton" <wfp5p@virginia.edu>, <netdev@vger.kernel.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>,
	"Greg KH" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40345 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754485Ab2KZJeU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 04:34:20 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09183-02 for <netdev@vger.kernel.org>;
 Mon, 26 Nov 2012 09:34:11 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <alpine.LFD.2.02.1211260425240.25230@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Even those don't care about less than 5k of memory, do they?
> 
>  I guess you're right.  As long as it's not 5k per driver +
> who_knows_how_much per platform for some generic stuff that is.  Of course
> this is still a waste, but I can accept it as a compromise between the use

If you are worried about that much memory (eg for a small embedded Linux)
I'r worry about the sizes of all the hash tables that keep popping up.
At least some of them really need converting to some kind of tree.

	David
