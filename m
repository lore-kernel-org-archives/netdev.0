From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 09:52:55 +0100
Message-ID: <20080116085254.GB2307@ff.dom.local>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com> <478D8FC8.9000107@trash.net> <20080116080259.GB1638@ff.dom.local> <478DBADB.1080200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:4695 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbYAPIqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 03:46:36 -0500
Received: by ug-out-1314.google.com with SMTP id z38so183371ugc.16
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 00:46:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <478DBADB.1080200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 09:05:47AM +0100, Patrick McHardy wrote:
...
> Yes, thats one possibility (without the dummy device though please).
> But I wonder what this would actually be useful for. I don't think
> replacing the root qdisc by a different type is a common scenario,
> for the same type you can simply use "tc qdisc change", "tc class
> change" and "tc class replace".
>
> Badalian, what are you actually doing?

I'm not sure Vyacheslav needs just this, but I've thought about the
possibility to recreate the 'shadow' copy of currently used qdisc
tree (with some updates of course) while it's running. So, the
possibility of using all the same handles and classids, and even
dev names if possible, and doing such a switch without any visible
break.

Jarek P.
