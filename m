From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: correction to docstring in get_unique_item
Date: Tue, 31 Oct 2017 14:42:54 -0400
Message-ID: <CAMDBHYJi6Zy9m7nwJAq-A5gLanto+0i8XjG0b4J5Vs5jt26qSg@mail.gmail.com>
References: <20171031182802.9772-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, Chris Mi <chrism@mellanox.com>,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Brenda J. Butler" <bjb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:53663 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932673AbdJaSnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:43:15 -0400
Received: by mail-wm0-f49.google.com with SMTP id r196so763800wmf.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:43:15 -0700 (PDT)
In-Reply-To: <20171031182802.9772-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:28 PM, Brenda J. Butler <bjb@mojatatu.com> wrote:
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
> ---
>  tools/testing/selftests/tc-testing/tdc_helper.py | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/tools/testing/selftests/tc-testing/tdc_helper.py b/tools/testing/selftests/tc-testing/tdc_helper.py
> index c3254f861fb2..6f99a4efe761 100644
> --- a/tools/testing/selftests/tc-testing/tdc_helper.py
> +++ b/tools/testing/selftests/tc-testing/tdc_helper.py
> @@ -15,7 +15,7 @@ def get_categorized_testlist(alltests, ucat):
>
>
>  def get_unique_item(lst):
> -    """ For a list, return a set of the unique items in the list. """
> +    """ For a list, return a list of the unique items in the list. """
>      return list(set(lst))
>
>
> --
> 2.15.0.rc0
>

Acked-by: Lucas Bates <lucasb@mojatatu.com>
