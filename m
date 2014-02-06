From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: AX88179_178A USB3 ethernet adapter performance issue
Date: Thu, 6 Feb 2014 17:17:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B9B5B@AcuExch.aculab.com>
References: <CAMVG2ssoBwk56n-k5VB9yO2LP4wc+gTv4o_17r-WYakwE6h2uQ@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B9A21@AcuExch.aculab.com>
 <20140206171239.GB16792@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Daniel J Blueman' <daniel@quora.org>,
	Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Netdev <netdev@vger.kernel.org>
To: 'Sarah Sharp' <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:32921 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754482AbaBFRSG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 12:18:06 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16795-01 for <netdev@vger.kernel.org>;
 Thu,  6 Feb 2014 17:18:00 +0000 (GMT)
In-Reply-To: <20140206171239.GB16792@xanatos>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarah Sharp
> > I have seem line rate Ge from my ax88179 card, but only with a
> > patched kernel.
> 
> David, did you mean you have the same line rate as Daniel?

No I meant I've seen it saturate a Ge link (with sufficiently large frames).

With very small frames the tx rate gets limited to a nice round number.
Possibly because the usb message rate limit.
It is high enough that it really doesn't matter, the code could put multiple
frames in a single URB, but I'm not sure the NAPI processing loop makes that
easy.

The receive side will run at a higher packet rate.

	David
