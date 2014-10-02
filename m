From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] tests: Dont fail cls-testbed.t if tests/cls dir
 is empty
Date: Thu, 2 Oct 2014 11:35:07 +0300
Message-ID: <CAMw6YJLEujeJqNJ1c94dv8eUt2u1M1vvLCQzgoUPguOVj8s1YA@mail.gmail.com>
References: <1412031436-14492-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vadim Kochan <vadim4j@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35950 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbaJBIfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 04:35:08 -0400
Received: by mail-wi0-f171.google.com with SMTP id em10so551810wid.16
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 01:35:07 -0700 (PDT)
In-Reply-To: <1412031436-14492-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Please ignore this patch, I will send modified one with another sibject.

On Tue, Sep 30, 2014 at 1:57 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> Curently tests/cls-testbed.t tries to run any *.t in
> tests/cls/ folder but such folder does not exist.
>
> The better solution can be like having a generic mechanism which
> allows to SKIP some tests (by return code?).
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  testsuite/tests/cls-testbed.t | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/testsuite/tests/cls-testbed.t b/testsuite/tests/cls-testbed.t
> index efae2a5..be32d79 100755
> --- a/testsuite/tests/cls-testbed.t
> +++ b/testsuite/tests/cls-testbed.t
> @@ -5,6 +5,11 @@ source lib/generic.sh
>
>  QDISCS="cbq htb dsmark"
>
> +if [ ! -d tests/cls ]; then
> +    ts_log "tests/cls folder is empty"
> +    exit 0
> +fi
> +
>  for q in ${QDISCS}; do
>         ts_log "Preparing classifier testbed with qdisc $q"
>
> --
> 2.1.0
>
