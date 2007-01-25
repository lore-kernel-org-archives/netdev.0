From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought up
Date: Thu, 25 Jan 2007 13:57:40 +0100
Message-ID: <a32f33a40701250457n69fd6c58ya4c4911d7528df79@mail.gmail.com>
References: <1169707854.10593.41.camel@dv>
	 <a32f33a40701250347q5c9aa5fby785181f77fc9bb4@mail.gmail.com>
	 <20070125135033.7d7d7baf@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Pavel Roskin" <proski@gnu.org>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
To: "Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:5817 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965276AbXAYM5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 07:57:43 -0500
Received: by nf-out-0910.google.com with SMTP id o25so840766nfa
        for <netdev@vger.kernel.org>; Thu, 25 Jan 2007 04:57:42 -0800 (PST)
In-Reply-To: <20070125135033.7d7d7baf@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > Correct, similar problems have been detected in rt2x00. The temporary
> > solution in there is to demand a scanning operation after the interface
> > has been brought up.
>
> Scanning? No no no, please! That would be a clear bug and misbehaviour.

Hmm, I think I forgot to add one little thing in my comment.
The scanning operation is demanded in the rt2x00 README, so the driver
doesn't start the scanning automatically and just awaits the user commands.
The user is also free to change the channel to make the configuration active.
But a scanning command will also display if it has at least found some AP,
so without scanning results attempting to scan will very likely fail. ;)

Ivo
