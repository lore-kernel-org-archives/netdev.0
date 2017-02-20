From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net 0/4] update ipvs sysctl document
Date: Mon, 20 Feb 2017 16:19:45 +0800
Message-ID: <CAPwn2JTc84Nw1GyEBbS97XBye0o1HbcwxBpLoVdwC1XSiWKwFw@mail.gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com> <alpine.LFD.2.11.1702191552560.1590@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        network dev <netdev@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:32871 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbdBTITs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 03:19:48 -0500
In-Reply-To: <alpine.LFD.2.11.1702191552560.1590@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,

Thanks a lot for the comments. I will send a v2 patch.

Regards
Hangbin

2017-02-19 22:04 GMT+08:00 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Fri, 17 Feb 2017, Hangbin Liu wrote:
>
>> Fix and add some new ipvs sysctl options. Also use tab instead of whitespaces
>> to indent the descriptions.
>
>         You change only docs, so the patchset should be for
> the net-next tree.
>
>> Hangbin Liu (4):
>>   ipvs: fix sync_threshold description and add sync_refresh_period,
>>     sync_retries
>>   ipvs: Document sysctl sync_qlen_max and sync_sock_size
>
> - we can add "are " here but then also check if lines become too long:
>
> "Hard limit for queued sync messages that [are ]not sent yet."
>
>         You can also move the "commit" word to next line
> to make checkpatch happy:
>
> scripts/checkpatch.pl --strict /tmp/file2.patch
>
>>   ipvs: Document sysctl sync_ports
>>   ipvs: Document sysctl pmtu_disc
>
> - we can make it like this:
>
> "By default, reject with FRAG_NEEDED all DF packets that exceed
> the PMTU, irrespective of the forwarding method. For TUN method
> the flag can be disabled to fragment such packets."
>
>>  Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
>>  1 file changed, 60 insertions(+), 8 deletions(-)
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
