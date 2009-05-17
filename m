From: Claude Robitaille <clauder@accedian.com>
Subject: Re: sk_buff handling in packet handler
Date: Sun, 17 May 2009 13:23:49 -0400
Message-ID: <4A104825.4000201@accedian.com>
References: <20090517102548.0a55d5bd.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060308030307010800070505"
Cc: netdev@vger.kernel.org
To: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:24273 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbZEQRYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 13:24:09 -0400
Received: by qw-out-2122.google.com with SMTP id 5so2236237qwd.37
        for <netdev@vger.kernel.org>; Sun, 17 May 2009 10:24:08 -0700 (PDT)
In-Reply-To: <20090517102548.0a55d5bd.ipng@69706e6720323030352d30312d31340a.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060308030307010800070505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Thanks Mark.

very interesting

this helped me but just to get to next problem....

what I am trying to do is to receive frame using a packet handler, 
manipulate it and send a portion of it over a UDP channel. I am using 
sock_sendmsg. Things sort of work but I get some warnings while in 
net_tx_action (via the sendmsg I am guessing) about doing scheduling 
while in atomic and sometime the kernel simply completely crashes. All 
this probably means that using kernel socket functions cannot be used 
from any context.... Any suggestion on how to properly do this? 
Ultimately, I'd like to avoid copying the data so if I could simply send 
an skb to some UDP TX handler would be ideal but if not, what is the 
best approach?

Thanks

Claude

Mark Smith wrote:
> Hi Claude,
>
> You could have a look at my Ethernet Configuration Testing Protocol
> (ECTP) implementation. I followed what other protocols did regarding
> packet/skb handling, and also tried to make it very clear what was
> required, as I struggled a bit with similar issues that you are. The
> routine to start with is ectp_rcv().
>
> http://lwn.net/Articles/330797/
>
> Regards,
> Mark.
>
>   

-- 
Claude Robitaille
CTO
Accedian Networks
514-764-0119
clauder@accedian.com


--------------060308030307010800070505
Content-Type: text/x-vcard; charset=utf-8;
 name="clauder.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="clauder.vcf"

begin:vcard
fn:Claude Robitaille
n:Robitaille;Claude
email;internet:clauder@accedian.com
tel;work:514-764-0119
tel;cell:514-796-7225
x-mozilla-html:TRUE
version:2.1
end:vcard


--------------060308030307010800070505--
