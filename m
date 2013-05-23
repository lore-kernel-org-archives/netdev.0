From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] ipv4: netfilter: always let NUL terminated string ended
 by '\0'
Date: Thu, 23 May 2013 19:39:39 +0800
Message-ID: <519DFFFB.40104@asianux.com>
References: <5195ECB3.5000006@asianux.com> <20130523110832.GB22553@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130523110832.GB22553@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2013 07:08 PM, Pablo Neira Ayuso wrote:
> On Fri, May 17, 2013 at 04:39:15PM +0800, Chen Gang wrote:
>> > 
>> > For NUL terminated string, better always be sure of ended by '\0'.
>> > 
>> > 'pm' is 'struct ulog_packet_msg_t' which may be copied to user mode
>> > (defined in "include/uapi/..."), so can not use strlcpy() instead of.
> loginfo->prefix is always nul-terminated, as this is validated in
> checkentry. I don't think the kernel will take a non nul-terminated
> device name either.
> 
> 

Really it is.

And 'prefix' max length is 128 (NF_LOG_PREFIXLEN), and 'pm->prefix' max
length is 32 (ULOG_PREFIX_LEN), so we still need this patch, but need
improved.

So I should send patch v2.


Thanks.
-- 
Chen Gang

Asianux Corporation
