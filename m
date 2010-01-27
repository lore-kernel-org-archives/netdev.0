From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: Network QoS support in applications
Date: Wed, 27 Jan 2010 17:18:05 +0100
Message-ID: <b2cc26e41001270818hfa9a533le4aa45a5f2f62eb8@mail.gmail.com>
References: <87k4v5nuej.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Kalle Valo <kalle.valo@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:48324 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab0A0QSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 11:18:09 -0500
In-Reply-To: <87k4v5nuej.fsf@purkki.valot.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 26, 2010 at 9:27 AM, Kalle Valo <kalle.valo@iki.fi> wrote:
> I would like to clear up all this by and I'm willing to write a
> document for application developers about network QoS. But I need help
> to understand what's the proper way to mark different QoS
> prioritities.

Maybe it shouldn't be done by applications, unless the streams of an
app use different priorities.
It might be useful to look at configuration of networked apps in a
broader sense, including stuff like to what IP addresses and ports an
app should bind. Maybe even to what Unix sockets or other transports.
Being able to configure this in one central place is way easier then
having to dive into the conf file of each individual application.
In this central place the QoS stuff could be configured too.

As this doesn't require application support, it's probably easier to
implement. It also provides more flexibility and maybe even more
security.

Olaf
