From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Tue, 15 Jan 2008 23:49:57 +0100
Message-ID: <20080115224956.GC2680@ami.dom.local>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com> <20080116004602.zn4y94e8sg0w4o8k@mail.bigtelecom.ru> <20080116010459.676cchrf8ko4wk8o@mail.bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:27153 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbYAOWp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 17:45:59 -0500
Received: by nf-out-0910.google.com with SMTP id g13so11904nfb.21
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 14:45:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080116010459.676cchrf8ko4wk8o@mail.bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 01:04:59AM +0300, slavon@bigtelecom.ru wrote:
> Good night! =)

Good morning! ;)

>
> Sorry... i was wrong...
> I see that problem more serious....
>
> Lets see to scheme
>
> Class 1
> ---qdisc
> ------- 10k classes
> Class 2
> ---qdisc
> ------- 10k classes
>
> All traffic go to class 2... class 1 qdisc not have packets and if we 
> delete it - packets not lost... in theory... lets try delete class 1 qdisc 
> (all childrens delete too)...
> PC freeze on 2-5 seconds... its not forward any traffic at this moment... 
> its great tree lock?
>
> Its normal or code need to more accurate lock?

I don't think it's normal. On the other hand I've never had such
problems... Probably this all isn't optimized for such big operations,
so maybe you should try to do this with some smaller chunks?

Jarek P.
