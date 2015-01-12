From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] team: Remove dead code
Date: Mon, 12 Jan 2015 08:10:48 +0100
Message-ID: <20150112071048.GA1873@nanopsycho.orion>
References: <20150112004351.GA8744@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kenneth Williams <ken@williamsclan.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39494 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbALHKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 02:10:51 -0500
Received: by mail-we0-f174.google.com with SMTP id k48so17355243wev.5
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 23:10:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150112004351.GA8744@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 12, 2015 at 01:43:54AM CET, ken@williamsclan.us wrote:
>The deleted lines are called from a function which is called:
>1) Only through __team_options_register via team_options_register and
>2) Only during initialization / mode initialization when there are no
>ports attached.
>Therefore the ports list is guarenteed to be empty and this code will
>never be executed.
>
>Signed-off-by: Kenneth Williams <ken@williamsclan.us>

Acked-by: Jiri Pirko <jiri@resnulli.us>
