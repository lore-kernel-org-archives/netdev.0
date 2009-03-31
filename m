From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 2/2 V2] kaweth: Clean up code
Date: Tue, 31 Mar 2009 23:49:53 +0200
Message-ID: <200903312349.53998.oliver@neukum.org>
References: <49d26531.EsrSuMQHYRGUbhou%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:41068 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763546AbZCaVpq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 17:45:46 -0400
In-Reply-To: <49d26531.EsrSuMQHYRGUbhou%Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag 31 M=E4rz 2009 20:47:13 schrieb Larry Finger:
> The driver kaweth yields a -EBUSY error when starting, and a -ETIME
> error when shutting down. These errors are avoided, and the RX status
> is further checked for other potential errors.

Why the different treatment with respect to the error counter?
Isn't enough to print the numerical error? This takes a lot of
memory.

	Regards
		Oliver

