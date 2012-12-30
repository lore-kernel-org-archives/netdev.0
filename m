From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] team: update master carrier state
Date: Sun, 30 Dec 2012 23:10:52 +0100
Message-ID: <20121230221052.GF1575@minipsycho.orion>
References: <1356892049-14667-1-git-send-email-fbl@redhat.com>
 <20121230214723.GD1575@minipsycho.orion>
 <20121230220616.GA2065@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:60384 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab2L3WK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 17:10:56 -0500
Received: by mail-ee0-f42.google.com with SMTP id c41so5834844eek.15
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 14:10:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121230220616.GA2065@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 30, 2012 at 11:06:16PM CET, fbl@redhat.com wrote:
>On Sun, Dec 30, 2012 at 10:47:23PM +0100, Jiri Pirko wrote:
>> Sun, Dec 30, 2012 at 07:27:29PM CET, fbl@redhat.com wrote:
>> >Update master's carrier state when there is any
>> >change with its ports.
>> 
>> 
>> This patch looks good to me. Just one nitpick I spotted....
>> 
>> >+	bool team_linkup;
>> >+
>> >+	team_linkup = false;
>> 
>> 
>> This can be squashed together.
>
>Ok, but that increases the static size of the module because it
>moves the variable out of bss.
>
>I have no strong opinion on either case, so it's up to you.

Ok :)

Acked-by: Jiri Pirko <jiri@resnulli.us>
