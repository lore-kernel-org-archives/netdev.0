From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH] pppoe: Use workqueue to die properly when a PADT is
 received
Date: Fri, 20 Feb 2015 20:49:23 +0100
Message-ID: <20150220204923.13275ydcca5wwwcj@berry.schulz.ip-v6.eu>
References: <1424381068-22252-1-git-send-email-simon@farnz.org.uk>
 <20150220171014.3970204f0h4aebmu@berry.schulz.ip-v6.eu>
 <2498181.kKNYHvd3hx@f19simon>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	mostrows@gmail.com, linux-ppp@vger.kernel.org
To: Simon Farnsworth <simon@farnz.org.uk>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <2498181.kKNYHvd3hx@f19simon>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Simon Farnsworth schrieb am Fri, 20 Feb 2015 16:41:17 +0000:

>> Feb 20 16:45:44 sandbox local2.err pppd[539]: Failed to disconnect
>> PPPoE socket: 114 Operation already in progress
>>
> I assume there's nothing else wrong here, other than pppd complaining? The
> code doesn't suggest there will be issues if we fail to disconnect.

Yes, there are no further problems beside the message. Nevertheless I  
wanted to mention it because any error message containing something  
like "Failed to disconnect" may upset the user. Of course, most PPPoE  
users nowadays use a flat rate for accessing the Internet and need not  
worry much about a "failed" disconnection, but you never know for  
sure...


Regards,

Christoph Schulz

