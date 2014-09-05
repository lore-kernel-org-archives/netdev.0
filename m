From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2] add help command to bonding master
Date: Fri, 5 Sep 2014 15:53:55 +0200
Message-ID: <20140905135355.GC1923@nanopsycho.lan>
References: <1409923456-14596-1-git-send-email-jiri@resnulli.us>
 <CAMw6YJKkiQtvN88rKLj=SEC3eFJyDA8WDX82tZtJh2zRW6-71w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	nikolay@redhat.com
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:55810 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323AbaIENyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:54:02 -0400
Received: by mail-we0-f170.google.com with SMTP id p10so11901769wes.15
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:54:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMw6YJKkiQtvN88rKLj=SEC3eFJyDA8WDX82tZtJh2zRW6-71w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 05, 2014 at 03:41:14PM CEST, vadim4j@gmail.com wrote:
>Sorry, may be this is not related to this particular patch:
>
>    would not it better to use usage() name instead of explain() as it
>is used everywhere ?

Well, yes, that is certainly doable. Feel free to send patch.


>
>On Fri, Sep 5, 2014 at 4:24 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  ip/iplink_bond.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
>> index b5c511e..0a1ed03 100644
>> --- a/ip/iplink_bond.c
>> +++ b/ip/iplink_bond.c
>> @@ -339,6 +339,9 @@ static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
>>                         }
>>                         ad_select = get_index(ad_select_tbl, *argv);
>>                         addattr8(n, 1024, IFLA_BOND_AD_SELECT, ad_select);
>> +               } else if (matches(*argv, "help") == 0) {
>> +                       explain();
>> +                       return -1;
>>                 } else {
>>                         fprintf(stderr, "bond: unknown command \"%s\"?\n", *argv);
>>                         explain();
>> --
>> 1.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
