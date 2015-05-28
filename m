From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH/RFC net-next] rocker: remove rocker parameter from
 functions that have rocker_port parameter
Date: Thu, 28 May 2015 09:18:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB417A2@AcuExch.aculab.com>
References: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Simon Horman' <simon.horman@netronome.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:55086 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbE1JUR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 05:20:17 -0400
In-Reply-To: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman
> Sent: 28 May 2015 04:23
> The rocker (switch) of a rocker_port may be trivially obtained from
> the latter it seems cleaner not to pass the former to a function when
> the latter is being passed anyway.

If the arguments are passed in registers (they almost certainly are)
or the function is inlined (possible since they are static) and
the calling code already has both values in registers then
passing both values saves a memory read inside the called code.

So on 'hot paths' it probably makes sense to pass both values.

	David
