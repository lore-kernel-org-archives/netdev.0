From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Wed, 18 Oct 2006 16:31:40 +0200
Message-ID: <200610181631.41433.dpc@asn.pl>
References: <200610151820.22867.dpc@asn.pl> <17717.40394.531846.695392@localhost.localdomain> <200610181115.12471.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:31191 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S932100AbWJRObp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 10:31:45 -0400
To: "Stephen J. Bevan" <stephen@dino.dnsalias.com>
In-Reply-To: <200610181115.12471.dpc@asn.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 18 October 2006 11:15, Dawid Ciezarkiewicz wrote:

> > * Given your desire not to change the size of the payload you have no
> >   space for MAC.  This makes it easier (but by no means easy) to alter
> >   the payload in such a way that it is still decrypted and considered
> >   valid.
> 
> Could you explain it more? I don't understand. You mean MAC as ... ?

Oh. Sorry. You mean message authentication code. Well - ccrypt have to live 
without it. From the start I knew that integrity will be the weakest point of 
ccrypt.
