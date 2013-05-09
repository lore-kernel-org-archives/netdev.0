From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] packet: tpacket_v3: do not trigger bug() on wrong
 header status
Date: Thu, 09 May 2013 20:32:52 +0200
Message-ID: <518BEBD4.5020003@redhat.com>
References: <1367585820-2674-1-git-send-email-dborkman@redhat.com> <CAAsGZS7TVr2YX8H8EQRqk4gDwNMQiaOkjhwCuLM_27RqB6+QgQ@mail.gmail.com> <518968DF.9070008@redhat.com> <CAAsGZS5SrH7vJ=dd+2JkpAF7RS1UGv09kU+nCjw-qXhDV7SZTA@mail.gmail.com> <518AF306.8020307@redhat.com> <CAAsGZS49POkSAumqQPkVT61i3Tz7+qqiRL5C2HrUCENTW5xw+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257Ab3EISdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 May 2013 14:33:01 -0400
In-Reply-To: <CAAsGZS49POkSAumqQPkVT61i3Tz7+qqiRL5C2HrUCENTW5xw+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2013 08:11 PM, chetan loke wrote:
> On Wed, May 8, 2013 at 8:51 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
[..]
> Normally people(sane code) will look for the return value from a
> syscall. mmap is special because there's no syscall to run once you
> mmap/setup the rings. Since there's no syscall there's no return
> value. That's why we try to detect it at run-time and try to WARN the
> user if we can.

Well, I'm aware of all the internals and the problem statement. No need
for further explanations.

I also don't want to have endless, tiring discussions on netdev about a
WARN_ON_ONCE statement either.

I still don't like it for the reasons I stated ;-) but if you want to send
a patch, I'm not going to stand in the way.
