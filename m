From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 V2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 15:04:09 -0700 (PDT)
Message-ID: <20090331.150409.149323548.davem@davemloft.net>
References: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net>
	<200903312350.38658.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry.Finger@lwfinger.net, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35295
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754811AbZCaWEV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 18:04:21 -0400
In-Reply-To: <200903312350.38658.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Oliver Neukum <oliver@neukum.org>
Date: Tue, 31 Mar 2009 23:50:38 +0200

> Am Dienstag 31 M=E4rz 2009 20:45:49 schrieb Larry Finger:
> > On an SMP system, the following message is printed. The patch below=
 gets
> > fixes the problem.
>=20
> Are you sure it is never called with disabled interrupts?

Please be specific, what is this "it" you are referring to?

Larry's patch modifies the locking many functions, and you didn't
quote the kernel locking error message if that provides the context of
your comment.
