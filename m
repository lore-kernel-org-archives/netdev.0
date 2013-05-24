From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] ipv4: netfilter: always let NUL terminated string
 ended by '\0'
Date: Fri, 24 May 2013 09:11:08 +0800
Message-ID: <519EBE2C.1010005@asianux.com>
References: <5195ECB3.5000006@asianux.com> <20130523110832.GB22553@localhost> <519E0296.6010601@asianux.com> <20130523122631.GA32141@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130523122631.GA32141@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2013 08:26 PM, Pablo Neira Ayuso wrote:
> On Thu, May 23, 2013 at 07:50:46PM +0800, Chen Gang wrote:
>> > 
>> > For NUL terminated string, need always be sure of ended by '\0'.
>> > 
>> > 'prefix' max length is 128 (NF_LOG_PREFIXLEN), and 'pm->prefix' max
>> > length is 32 (ULOG_PREFIX_LEN), so really need notice it.
>> > 
>> > 'pm' is 'struct ulog_packet_msg_t' which may be copied to user mode
>> > (defined in "include/uapi/..."), so can not use strlcpy() instead of.
> That's fixing a real bug. We're passing strings that are longer than
> 32 bytes from nf_conntrack_tcp via nf_log, if ipt_ULOG is used, it
> will pass a non-null terminated string.
> 
> I'm going to rework the patch description to include this and apply
> this patch.
> 
> Thanks Chen.
> 
> 

Thank you too.

-- 
Chen Gang

Asianux Corporation
