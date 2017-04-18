From: Mike Maloney <maloneykernel@gmail.com>
Subject: Re: [PATCH net] selftests/net: Fixes psock_fanout CBPF test case
Date: Tue, 18 Apr 2017 11:56:56 -0400
Message-ID: <CAJegeYmU4ntddE8cHFZT5QM0=aOzu0s1pYkQMehREv56JorEog@mail.gmail.com>
References: <20170418151416.17858-1-maloneykernel@gmail.com> <20170418152616.GE18699@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        Mike Maloney <maloney@google.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f176.google.com ([209.85.217.176]:36424 "EHLO
        mail-ua0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751849AbdDRP45 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:56:57 -0400
Received: by mail-ua0-f176.google.com with SMTP id a1so94048526uaf.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 08:56:57 -0700 (PDT)
In-Reply-To: <20170418152616.GE18699@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 11:26 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (04/18/17 11:14), Mike Maloney wrote:
>> Change 'psock_fanout' to use SOCK_RAW so that the CBPF program used with
>> SO_ATTACH_FILTER can examine the entire frame.  Create a new CBPF
>> program for use with PACKET_FANOUT_DATA which ignores the header, as it
>> cannot see the ethernet header.
>
> Fix look good to me, but could you please also add the bpf_asm input
> as a comment to the C code, in case we want to to read/extend  this
> down the road?
>
> --Sowmini
>

I am not 100% sure what you are asking for, as the instructions you
can feed to bpf_asm are already commented to the right of the program.

-Mike
