From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] (5/6) ibmtr -- probe2
Date: Fri, 17 Oct 2003 10:34:54 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF2CF9F939.3E58DC8A-ON84256DC2.004A4CEF-84256DC2.004A9B73@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>>
>> > typedef struct ibmtr_dev_t {
>> > +    struct tok_info         ti;         /* must be first! */
>>
>> Why must this be first ?? Sounds like an alignment issue, we shouldn't
>> assume some is aligned correctly just because it's the first entry.

>Because ibmtr_cs calls ibmtr_probe1 function which does:
>            struct tok_info *ti = dev->priv;
>and dereferences it in a couple of places.

Huh ?? All the patch did was move the definition of ti to the start of the
struct ibmtr_dev_t

Mike
