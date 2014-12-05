From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2 REGRESSIONS v2] ss: Fix layout/output issues
 introduced by regression
Date: Fri, 5 Dec 2014 19:21:33 +0200
Message-ID: <20141205172133.GA25321@angus-think.wlc.globallogic.com>
References: <1417791796-7739-1-git-send-email-vadim4j@gmail.com>
 <5481E77C.7070102@cogentembedded.com>
 <20141205170641.GA23226@angus-think.wlc.globallogic.com>
 <5481E9E0.6080809@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:40525 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaLERbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:31:19 -0500
Received: by mail-la0-f50.google.com with SMTP id pn19so1069955lab.9
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 09:31:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5481E9E0.6080809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 05, 2014 at 08:22:40PM +0300, Sergei Shtylyov wrote:
 >>>  					sizeof(prot_name)));
> >>>-	}
> >>>+	} else
> >>>+		printf("%*d:", addr_width, prot);
> >>>+
> 
> >>    Extra empty line hardly needed here. And if iproute2 follows the Linux
> >>kernel style, {} should be used in all arms of the *if* statement (since
> >>it's used in one case).
> 
> >>>
> >>>  	if (pid == -1) {
> >>>  		printf("%-*s ", serv_width, "*");
> 
> >You mean change to this ?
> 
> >	if (resolve_services) {
> >  		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
> >  					sizeof(prot_name)));
> >	} else {
> >		printf("%*d:", addr_width, prot);
> >         }
> 
>    Yes (but indent } with tab please).
> 
> >Thanks,
> 
> WBR, Sergei
> 
> 

Thanks for comments, I have sent a v3.

Regards,
Vadim
