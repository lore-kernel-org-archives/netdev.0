From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
Date: Mon, 12 Mar 2012 09:37:47 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E99@saturn3.aculab.com>
References: <CAOD=uF4Vx581zvpAT0dHKjUkrdsiZo-DTNR352V8tALM_P2roA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sony Chacko" <sony.chacko@qlogic.com>,
	"netdev" <netdev@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: "santosh prasad nayak" <santoshprasadnayak@gmail.com>,
	"Rajesh Borundia" <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47357 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755054Ab2CLJiq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 05:38:46 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11831-03 for <netdev@vger.kernel.org>;
 Mon, 12 Mar 2012 09:38:42 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CAOD=uF4Vx581zvpAT0dHKjUkrdsiZo-DTNR352V8tALM_P2roA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of santosh 
> prasad nayak
> Sent: 11 March 2012 09:17
> To: Rajesh Borundia
> Cc: Sony Chacko; netdev; linux-kernel; kernel-janitors@vger.kernel.org
> Subject: Re: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
> 
> Thanks Rajesh for clarification.
> Included all your inputs in the following patch.
> This is for review not a formal one. Once review is done I will send a
> formal patch.

I'm not sure of the exact nature of the issues here,
but whenever I see code that casts between the addresses
of integer types large bells start ringing - such code
tends to have unwanted dependencies against the sizes
and endiannesses of the relevant fields.
This code might be ok, but lines like:
> +	if (*(__le64 *)mac == cpu_to_le64(~0ULL)) {
rather give me the willies.

	David
