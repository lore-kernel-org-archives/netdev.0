From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: detect loss above high_seq in recovery
Date: Tue, 3 Jan 2012 10:54:03 -0800
Message-ID: <CAK6E8=eJU0puyqWsJg-7FESMEdHZgx3FXCMkxM7+rUyrSg1Hdg@mail.gmail.com>
References: <1325033182-25905-1-git-send-email-ycheng@google.com>
 <alpine.DEB.2.00.1112281736480.7752@melkinpaasi.cs.helsinki.fi>
 <CAK6E8=fu_KAnzMhKYa368BzhGkLGtjjPhvDUezQ_b6Nsd5o6Zw@mail.gmail.com> <alpine.DEB.2.00.1112301256060.15137@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ncardwell@google.com,
	nanditad@google.com, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:62219 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754516Ab2ACSyY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 13:54:24 -0500
Received: by obcwo16 with SMTP id wo16so12801034obc.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 10:54:24 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1112301256060.15137@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2011 at 3:19 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Thu, 29 Dec 2011, Yuchung Cheng wrote:
>
>> To summarize:
>> 1) this change does NOT forbid TCP performing further CWR on new los=
ses
>> 2) this change (merely) marks some forward-retransmitted packets LOS=
T.
>> 3) the commit message is to be explicit that CWR may not always be p=
erformed,
>> =A0 =A0 in both my change and current kernel.
>
> I agree with these points. I wonder if you intend to look to fixing t=
he
> lacking CWR problem or should I look to that once I get some spare ti=
me?
>
>> HTH. I will update commit message if people can make sense of it :)
>
> Please do.
Great, I'll update the commit message first, and work on another
feature patch that does CWR if
a) new sequence is lost
b) a retransmission is lost
