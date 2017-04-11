From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 13:12:03 -0600
Message-ID: <76edbeae-f050-092a-2b6a-01cb7d68cd36@cumulusnetworks.com>
References: <20170411173143.GA1899@salvia>
 <20170411.134225.398046538225438175.davem@davemloft.net>
 <cb6106f2-3128-da79-69bf-a10b249db054@cumulusnetworks.com>
 <20170411.150527.283014710949232666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170411.150527.283014710949232666.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/11/17 1:05 PM, David Miller wrote:
> From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
> Date: Tue, 11 Apr 2017 12:57:59 -0600
> 
>> On 4/11/17 11:42 AM, David Miller wrote:
>>> David, if you have a specific case where it's absolutely impossible
>>> to resolve this when the library is converted to support extended
>>> ACKs, please mention it.
>>
>> I don't have a specific library in mind. It is more the disjoint nature
>> of a socket option and message parsing, and thinking through the API.
> 
> Would you prefer it being passed via a control message at sendmsg()
> time?  That would require more changes to userland programs, and also
> increase the per-request overhead in the kernel as it parses this CMSG
> every single time.

Johannes' v4 adds a flag in the response that the parser can use to
definitely know the size of the errmsg.msg that was returned. That seems
sufficient to me. Did you disagree with that suggestion?
