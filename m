From: =?UTF-8?Q?Mantas_Mikul=c4=97nas?= <grawity@gmail.com>
Subject: Re: regression (4.10) - interface remove uevents not generated
Date: Sun, 12 Mar 2017 12:55:59 +0200
Message-ID: <46817d29-340c-701c-0503-3db604f25429@gmail.com>
References: <d519f10b-8512-efa2-03a1-81f6e4a91c7c@gmail.com>
 <20170311195047.GA10561@outlook.office365.com>
 <3aff47fb-7dde-2d21-74bc-9954560a2b51@gmail.com>
 <20170311234324.GA15113@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>
To: Andrei Vagin <avagin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33148 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755667AbdCLK4F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 06:56:05 -0400
Received: by mail-lf0-f43.google.com with SMTP id a6so54435470lfa.0
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 03:56:03 -0700 (PDT)
In-Reply-To: <20170311234324.GA15113@outlook.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-12 08:51, Andrei Vagin wrote:
> On Sat, Mar 11, 2017 at 11:24:34PM +0200, Mantas Mikulėnas wrote:
>> On 2017-03-11 21:50, Andrei Vagin wrote:
>>> Hi Mantas,
>>>
>>> Thank you for the report. Could you try out the attached patch?
>>
>> Thanks, I tested it on current master but it doesn't seem to help; there
>> still aren't any uevents for removed interfaces.
> 
> I reproduced the issue on my host and the correct patch is attached to
> this message. Thanks!

Just tested, the new patch seems to be working fine here.

Thanks for the quick fix; any chance of getting it into 4.10.x as well?

-- 
Mantas Mikulėnas <grawity@gmail.com>
