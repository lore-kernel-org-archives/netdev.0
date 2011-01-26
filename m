From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: 40k+ outbound connections and bind() problem
Date: Wed, 26 Jan 2011 14:23:44 +0200
Message-ID: <AANLkTikSvf8bNK2_eHg+cWQJLz-56_88mrf0ttJX3W=0@mail.gmail.com>
References: <8cdb2dde69120a8668b31e2050916493@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:44849 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab1AZMXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 07:23:44 -0500
Received: by pzk35 with SMTP id 35so49124pzk.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 04:23:44 -0800 (PST)
In-Reply-To: <8cdb2dde69120a8668b31e2050916493@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Jan 26, 2011 at 2:14 PM,  <denys@visp.net.lb> wrote:
> I am running server (TCP accelerator), which is initiating more than 40K
> connections.
> Each instance of server bound to separate IP, and each of them handling
> around 5-10K connections.
> At moments, when i have excessive connect/disconnect events if i try to
> establish connection even from IP is not used,
> during bind() i am getting errno "Address already in use".
> What can be the issue?
> Will it help if i increase in kernel hardcoded limit from 64K TCP bind hash
> entries to higher values?

Please provide more information. What kernel version are you using?
Are you  binding on a SO_REUSEADDR socket right?

thanks,
Daniel.
