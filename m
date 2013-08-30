From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v10 11/11] ipv6: Add generic UDP Tunnel segmentation
Date: Fri, 30 Aug 2013 14:14:10 -0700
Message-ID: <CALnjE+rKhTKK6wptN=dwkaEEj9T0R-vu9Fr0q+xiGZQjLUfbFg@mail.gmail.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	<1377667379-2315-12-git-send-email-amwang@redhat.com>
	<CALnjE+p87D301m8oJ=rkJap44zcPkVp=YkThUT70fW1kkrQ9AQ@mail.gmail.com>
	<1377850563.2591.11.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:46346 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752525Ab3H3VOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:14:12 -0400
Received: by mail-qc0-f176.google.com with SMTP id u20so1110534qcx.21
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 14:14:10 -0700 (PDT)
In-Reply-To: <1377850563.2591.11.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 30, 2013 at 1:16 AM, Cong Wang <amwang@redhat.com> wrote:
> On Wed, 2013-08-28 at 10:55 -0700, Pravin Shelar wrote:
>> On Tue, Aug 27, 2013 at 10:22 PM, Cong Wang <amwang@redhat.com> wrote:
>> > From: Cong Wang <amwang@redhat.com>
>> >
>> > Similar to commit 731362674580cb0c696cd1b1a03d8461a10cf90a
>> > (tunneling: Add generic Tunnel segmentation)
>> >
>> Can we factor out ipv4-udp-tunnel code so that there is no duplicating code?
>
> Probably we can, but it will make code review harder? Or you mean doing
> it in a separated patch? If you insist, I can do it in a separated
> patch.
>

I doubt it makes review any harder. But separate patch is also fine with me.
