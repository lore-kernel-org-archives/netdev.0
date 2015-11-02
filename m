From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH net-next] af_unix: optimize unix_writable by inlining
Date: Mon, 02 Nov 2015 12:55:45 -0500
Message-ID: <f7th9l4476m.fsf@aconole.bos.csb>
References: <1446483719-30310-1-git-send-email-aconole@bytheb.org>
	<20151102.120822.1151065456395557870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33574 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbbKBRzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 12:55:48 -0500
Received: by qgeo38 with SMTP id o38so123207188qge.0
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 09:55:47 -0800 (PST)
In-Reply-To: <20151102.120822.1151065456395557870.davem@davemloft.net> (David
	Miller's message of "Mon, 02 Nov 2015 12:08:22 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Aaron Conole <aconole@bytheb.org>
> Date: Mon,  2 Nov 2015 12:01:59 -0500
>
>> unix_writable() originally was inlined, but was changed as part of
>> commit 1586a5877db9 ("af_unix: do not report POLLOUT on
>> listeners"). Re-enable the inline flag.
>> 
>> Signed-off-by: Aaron Conole <aconole@bytheb.org>
>
> This is never appropriate.
>
> The compiler should be fixed to inline functions properly when
> appropriate for the optimization level requested.

Okay, apologies for the noise.
