From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: sendfile() behavior while troubleshooting netdevice
Date: Tue, 29 Jul 2008 09:32:50 +0000
Message-ID: <20080729093250.GA13365@ff.dom.local>
References: <20080728190707.329d247b@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ian@jeffray.co.uk
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:34729 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbYG2J1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 05:27:36 -0400
Received: by ug-out-1314.google.com with SMTP id h2so125645ugf.16
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 02:27:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080728190707.329d247b@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-07-2008 02:07, Jay Cliburn wrote:
...
> file size is 1600 bytes
> received 1592 bytes
> error: expected 1600, received 1592

sfclient.c:
...
		prev = count;
		count += ret;
		if (prev == count) {
			fprintf(stderr, "error: expected %d, received %d\n",
				fsize, count);
--->			exit(1);
		}

Maybe you could try without this exit if anything comes later?

Jarek P.
