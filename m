From: Bjorn Andersson <bjorn@kryo.se>
Subject: Re: [PATCH v5 14/15] net: wireless: ath: Remove unneeded variable ret
 returning 0
Date: Fri, 23 Oct 2015 07:34:28 -0700
Message-ID: <CAJAp7OgZY+GMFBpU6TonZh+tvHiVC21pUAr0jPCDHjgS5On4Jg@mail.gmail.com>
References: <1445540254-4207-1-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	sergei.shtylyov@cogentembedded.com, jirislaby@gmail.com
To: Punit Vara <punitvara@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33930 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbJWOea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 10:34:30 -0400
Received: by lfaz124 with SMTP id z124so85866489lfa.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 07:34:29 -0700 (PDT)
In-Reply-To: <1445540254-4207-1-git-send-email-punitvara@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 11:57 AM, Punit Vara <punitvara@gmail.com> wrote:

Hi Punit,

> Remove empty line suggested by Sergei
>

A commit message is here to, in the future, help us all understand
what and why this change was made, so you should not include comments
about what you changed since a previous version of this patch.

> This patch is to the ath5k/eeprom.c that fixes up warning caught by
> coccicheck:
>

You don't need to indicate what files are changed in the commit
message, as that information is already available in the body of the
commit. And the comment stats the wrong file.

> Unneeded variable: "ret". Return "0" on line 980
>
> Remove unneeded variable ret created to return zero.
>

Both of these are only reiterating what the subject already states -
in two different ways. So you can easily remove them without loosing
any information. In fact, the subject is all you need to describe the
change.

Regards,
Bjorn
