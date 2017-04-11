From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 08:25:57 -0600
Message-ID: <9a68aa01-474c-7054-30c2-473ee1250abe@cumulusnetworks.com>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
 <20170408202434.12018-2-johannes@sipsolutions.net>
 <fddba2c8-3b85-d5df-81c4-ef31c459e40c@cumulusnetworks.com>
 <1491838218.28432.5.camel@sipsolutions.net>
 <029e6587-c0e8-bdb0-49e9-2abe2946a7ff@cumulusnetworks.com>
 <20170411065908.GB1492@salvia> <1491894172.31620.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1491894172.31620.2.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/11/17 1:02 AM, Johannes Berg wrote:
> On Tue, 2017-04-11 at 08:59 +0200, Pablo Neira Ayuso wrote:
>> CAP_ACK means: trim off the payload that the netlink error message
>> is embedding, just like ICMP error does.
>>
>> What is exactly your concern? If the user explicitly requests this
>> via socket option for this socket, then we're expecting they do the
>> right handling for what they're asking for.
> 
> I think David's concern was that when you want to parse the ACK in a
> library (or application), you may not easily know if the application
> (or library) requested capping.

exactly.
