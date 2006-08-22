From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Get rid of /proc/sys/net/unix/max_dgram_qlen
Date: Wed, 23 Aug 2006 00:39:14 +0400
Message-ID: <20060822203914.GA9246@ms2.inr.ac.ru>
References: <4550.81.207.0.53.1156275903.squirrel@81.207.0.53>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:1674 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932133AbWHVUjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 16:39:19 -0400
To: Indan Zupancic <indan@nul.nu>
Content-Disposition: inline
In-Reply-To: <4550.81.207.0.53.1156275903.squirrel@81.207.0.53>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Either this, or it should be implemented correctly, which means poll needs
> to be fixed to also check for max_dgram_qlen,

Feel free to do this correctly. :-)
Deleting "wrong" code rarely helps.

It is the only protection of commiting infinite amount of memory to a socket.

Alexey
