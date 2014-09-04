From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] net-timestamp: expand documentation
Date: Thu, 4 Sep 2014 10:03:14 -0400
Message-ID: <CA+FuTSd1hj7oik1uoA+pEMhAFFrqvvPk-OLS_7wDBg08ppW+uw@mail.gmail.com>
References: <1409534867-32710-1-git-send-email-willemb@google.com> <54086164.6030603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:35673 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbaIDODq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:03:46 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so10483508qcw.31
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 07:03:44 -0700 (PDT)
In-Reply-To: <54086164.6030603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +
>> +       data = malloc(cfg_payload_len);
>> +       if (!data)
>> +               error(1, 0, "malloc");
>> +
>> +       memset(&msg, 0, sizeof(msg));
>> +       memset(&entry, 0, sizeof(entry));
>> +       memset(ctrl, 0, sizeof(ctrl));
>> +       memset(data, 0, sizeof(data));
>
>
> I think this memset is wrong and should rather be
> something like :
>
>         memset(data, 0, cfg_payload_len);
>

Thanks, Daniel. I'll send a fix.
