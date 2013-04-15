From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 10:45:55 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71D1@saturn3.aculab.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com> <1365879412-9541-1-git-send-email-willemb@google.com> <5169D9C8.8010504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <paul.chavent@onera.fr>, <richardcochran@gmail.com>,
	<edumazet@google.com>, <daniel.borkmann@tik.ee.ethz.ch>,
	<xemul@parallels.com>, <ebiederm@xmission.com>,
	<netdev@vger.kernel.org>
To: "Daniel Borkmann" <dborkman@redhat.com>,
	"Willem de Bruijn" <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48166 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753092Ab3DOJq7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 05:46:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25290-09 for <netdev@vger.kernel.org>;
 Mon, 15 Apr 2013 10:46:55 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <5169D9C8.8010504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +	case TPACKET_V1:
> > +		h1 = frame;
> > +		h1->tp_sec = ts.tv_sec;
> > +		h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
> > +
> > +		flush_dcache_page(pgv_to_page(&h1->tp_sec));
> > +		flush_dcache_page(pgv_to_page(&h1->tp_usec));
> 
> Hmm, not sure, but could we also flush the dcache only once?

If it isn't a silly question, why is the dcache being flushed
here at all?

	David
