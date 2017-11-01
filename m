From: Brenda Butler <bjb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: split config file
Date: Tue, 31 Oct 2017 22:41:23 -0400
Message-ID: <CAEj_wPSVeSBeE=aemEtv-RUkgPDy8zgAz+f_i=W9dx7660XoBQ@mail.gmail.com>
References: <20171031182728.9725-1-bjb@mojatatu.com> <20171101.110623.348780136039045689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, Chris Mi <chrism@mellanox.com>,
        Lucas Bates <lucasb@mojatatu.com>,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:56303 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKAClY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:41:24 -0400
Received: by mail-ua0-f195.google.com with SMTP id b11so645140uae.12
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 19:41:24 -0700 (PDT)
In-Reply-To: <20171101.110623.348780136039045689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 10:06 PM, David Miller <davem@davemloft.net> wrote:
> From: "Brenda J. Butler" <bjb@mojatatu.com>
> Date: Tue, 31 Oct 2017 14:27:28 -0400
>
>> Move the config customization into a site-local file
>> tdc_config_local.py, so that updates of the tdc test
...
>> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
>
> Please always remove trailing empty lines in files, GIT even warns
> about this when one tries to apply the patch:
>
>> @@ -17,3 +17,17 @@ NAMES = {
>>            # Name of the namespace to use
>>            'NS': 'tcut'
>>          }
>> +
>  ...
>> +# example adding values to ENVIR, without editing tdc_config.py
>> +ENVIR['VALGRIND_LIB'] = '/usr/lib/valgrind'
>> +ENVIR['VALGRIND_BIN'] = '/usr/bin/valgrind'
>> +ENVIR['VGDB_BIN'] = '/usr/bin/vgdb'
>> +

Thank you, I will make sure to that.

bjb
