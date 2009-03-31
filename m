From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 V2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 23:50:38 +0200
Message-ID: <200903312350.38658.oliver@neukum.org>
References: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:60716 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763608AbZCaVq3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 17:46:29 -0400
In-Reply-To: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag 31 M=E4rz 2009 20:45:49 schrieb Larry Finger:
> On an SMP system, the following message is printed. The patch below g=
ets
> fixes the problem.

Are you sure it is never called with disabled interrupts?

	Regards
		Oliver

